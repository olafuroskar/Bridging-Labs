package dk.carp.muse_sdk

import android.bluetooth.BluetoothManager
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.choosemuse.libmuse.*
import io.flutter.plugin.common.EventChannel
import java.util.concurrent.atomic.AtomicReference

class MuseSdkController {
    private lateinit var manager: MuseManagerAndroid
    private var muse: Muse? = null
    private lateinit var context: Context

    private var connectionListener: MuseConnectionListener? = null
    private var dataListener: MuseDataListener? = null
    private var handler: Handler = Handler(Looper.getMainLooper())

    private val fileWriter = AtomicReference<MuseFileWriter>()
    private val fileHandler = AtomicReference<Handler>()
    private var dataTransmission = true

    private val maxBufferSize = 200

    private val eegBuffer = DoubleArray(6)
    private val ppgBuffer = DoubleArray(3)
    private val ppgDataBuffer: ArrayList<Pair<Long, DoubleArray>> = ArrayList()
    private val alphaBuffer = DoubleArray(6)
    private val accelBuffer = DoubleArray(3)

    private var eventSink: EventChannel.EventSink? = null
    private var dataEventSink: EventChannel.EventSink? = null

    fun setEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    fun setDataEventSink(sink: EventChannel.EventSink?) {
        dataEventSink = sink
    }

    fun initialize(appContext: Context) {
        context = appContext
        manager = MuseManagerAndroid.getInstance()
        manager.setContext(appContext)

        connectionListener = object : MuseConnectionListener() {
            override fun receiveMuseConnectionPacket(p: MuseConnectionPacket, muse: Muse) {
                Log.i(Companion.TAG, "Connection state: ${p.previousConnectionState} -> ${p.currentConnectionState}")
                if (p.currentConnectionState == ConnectionState.DISCONNECTED) {
                    this@MuseSdkController.muse = null
                }
            }
        }

        dataListener = object : MuseDataListener() {
            override fun receiveMuseDataPacket(p: MuseDataPacket, muse: Muse) {
                when (p.packetType()) {
                    MuseDataPacketType.PPG -> updatePpgBuffer(p)
                    MuseDataPacketType.EEG -> updateEegBuffer(p)
                    MuseDataPacketType.ACCELEROMETER -> updateAccelBuffer(p)
                    MuseDataPacketType.ALPHA_RELATIVE -> updateAlphaBuffer(p)
                    else -> {}
                }
            }

            override fun receiveMuseArtifactPacket(p: MuseArtifactPacket?, muse: Muse?) {}
        }

        manager.setMuseListener(object : MuseListener() {
            override fun museListChanged() {
                val muses = manager.muses
                Log.i(Companion.TAG, "Discovered ${muses.size} Muse(s)")
                // You can optionally notify Dart here

                eventSink?.success(mapOf(
                    "type" to "museListChanged",
                    "muses" to muses.map { it.name + " - " + it.macAddress }
                ))
            }
        })

        manager.startListening()

    }

    fun isBluetoothEnabled(): Boolean {
        val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        return bluetoothManager.adapter?.isEnabled == true
    }

    fun refreshMuseList() {
        manager.stopListening()
        manager.startListening()
    }

    fun connectToMuse(index: Int) {
        manager.stopListening()
        val availableMuses = manager.muses
        if (index in availableMuses.indices) {
            muse = availableMuses[index].apply {
                unregisterAllListeners()
                registerConnectionListener(connectionListener)
                // registerDataListener(dataListener, MuseDataPacketType.EEG)
                // registerDataListener(dataListener, MuseDataPacketType.ALPHA_RELATIVE)
                // registerDataListener(dataListener, MuseDataPacketType.ACCELEROMETER)
//                registerDataListener(dataListener, MuseDataPacketType.BATTERY)
//                registerDataListener(dataListener, MuseDataPacketType.DRL_REF)
                registerDataListener(dataListener, MuseDataPacketType.PPG)
                setPreset(MusePreset.PRESET_52)
                runAsynchronously()
            }
        } else {
            Log.w(Companion.TAG, "No Muse at index $index")
        }
    }

    fun disconnectMuse() {
        muse?.disconnect()
    }

    fun togglePause() {
        muse?.let {
            dataTransmission = !dataTransmission
            it.enableDataTransmission(dataTransmission)
        }
    }

    fun getLatestEeg(): DoubleArray = eegBuffer.copyOf()

    fun getLatestPpg(): DoubleArray = ppgBuffer.copyOf()

    private fun updateEegBuffer(packet: MuseDataPacket) {
        eegBuffer[0] = packet.getEegChannelValue(Eeg.EEG1)
        eegBuffer[1] = packet.getEegChannelValue(Eeg.EEG2)
        eegBuffer[2] = packet.getEegChannelValue(Eeg.EEG3)
        eegBuffer[3] = packet.getEegChannelValue(Eeg.EEG4)
        eegBuffer[4] = packet.getEegChannelValue(Eeg.AUX_LEFT)
        eegBuffer[5] = packet.getEegChannelValue(Eeg.AUX_RIGHT)
    }

    private fun updatePpgBuffer(packet: MuseDataPacket) {
        ppgBuffer[0] = packet.getPpgChannelValue(Ppg.IR)
        ppgBuffer[1] = packet.getPpgChannelValue(Ppg.RED)
        ppgBuffer[2] = packet.getPpgChannelValue(Ppg.AMBIENT)
        // `packet.timestamp()` Microseconds since epoch (usually Jan 1, 1970)
        ppgDataBuffer.add(Pair(packet.timestamp(), getLatestPpg()))
        if (ppgDataBuffer.size > maxBufferSize) {
            try {
                // Serialize for Flutter
                val serializedData = ppgDataBuffer.map { pair ->
                    mapOf(
                        "timestamp" to pair.first,
                        "values" to pair.second.toList()
                    )
                }
                dataEventSink?.success(mapOf(
                    "type" to "ppg",
                    "data" to serializedData
                ))
            } catch (e: Exception) {
                Log.e(Companion.TAG, e.toString())
            }
            ppgDataBuffer.clear()
        }
    }

    private fun updateAccelBuffer(packet: MuseDataPacket) {
        accelBuffer[0] = packet.getAccelerometerValue(Accelerometer.X)
        accelBuffer[1] = packet.getAccelerometerValue(Accelerometer.Y)
        accelBuffer[2] = packet.getAccelerometerValue(Accelerometer.Z)
    }

    private fun updateAlphaBuffer(packet: MuseDataPacket) {
        alphaBuffer[0] = packet.getEegChannelValue(Eeg.EEG1)
        alphaBuffer[1] = packet.getEegChannelValue(Eeg.EEG2)
        alphaBuffer[2] = packet.getEegChannelValue(Eeg.EEG3)
        alphaBuffer[3] = packet.getEegChannelValue(Eeg.EEG4)
    }

    companion object {
        private const val TAG = "MuseSdkController"
    }
}
