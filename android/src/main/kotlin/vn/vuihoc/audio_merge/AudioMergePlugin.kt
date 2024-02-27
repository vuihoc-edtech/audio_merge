package vn.vuihoc.audio_merge

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.net.Uri
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import zeroonezero.android.audio_mixer.AudioMixer
import zeroonezero.android.audio_mixer.input.GeneralAudioInput

/** AudioMergePlugin */
class AudioMergePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "audio_merge")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            Method.MERGE.name -> merge(call, result)
            Method.REQUEST_EXTERNAL_STORAGE.name -> requestExternalStorage(call, result)
            Method.GET_PLATFORM_VERSION.name -> getPlatformVersion(result)
            else -> result.notImplemented()
        }
    }

    // args model for merge method
    // {
    //   "background": "path/to/background.mp3",
    //   "output_path": "path/to/output.mp3",
    //   "script": {
    //     "0": "path/to/audio1.mp3",
    //     "4000": "path/to/audio2.mp3",
    //     "10000": "path/to/audio3.mp3",
    //     "15000": "path/to/audio4.mp3",
    //     "20000": "path/to/audio5.mp3",
    //     "25000": "path/to/audio6.mp3"
    //   }
    // }
    // Main feature of this plugin
    private fun merge(call: MethodCall, result: Result) {
        val args = call.arguments as Map<*, *>?
        val context = activity?.applicationContext
        val background = args?.get("background") as String?
        val output = args?.get("output_path") as String?
        val script = args?.get("script") as Map<*, *>?
        val mlS = 1000L

        val outputPath =
            output ?: (context?.filesDir?.absolutePath + "/" + "audio_mixer_output.mp3")
        val audioMixer = AudioMixer(outputPath)

        /// Set the sample rate, bit rate, channel count and mixing type
        audioMixer.setSampleRate(44100)
        audioMixer.setBitRate(128000)
        audioMixer.setChannelCount(1)
        audioMixer.mixingType = AudioMixer.MixingType.PARALLEL

        // Main audio mixer logic
        val inputBG = GeneralAudioInput(context, Uri.parse(background), null)
        inputBG.volume = 1.0f //Optional
        audioMixer.addDataSource(inputBG)
        // Add all the audio script to the audio mixer
        script?.forEach {
            val input = GeneralAudioInput(context, Uri.parse(it.value as String), null)
            input.startOffsetUs = (it.key as Int) * mlS
            audioMixer.addDataSource(input)
        }

        // Process and result callback to Flutter
        audioMixer.setProcessingListener(object : AudioMixer.ProcessingListener {
            override fun onProgress(progress: Double) {
                callFlutterMethod(Method.ON_PROGRESS, (progress * 100).toInt())
            }

            override fun onEnd() {
                callFlutterMethod(Method.ON_SUCCESS, outputPath)
                audioMixer.release()
            }
        })
        audioMixer.start()
        audioMixer.processSync()
        result.success(outputPath)
    }

    private fun requestExternalStorage(call: MethodCall, result: Result) {
        val permission =
            this.activity?.let {
                ActivityCompat.checkSelfPermission(
                    it,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
                )
            }

        if (permission != PackageManager.PERMISSION_GRANTED) {
            // We don't have permission so prompt the user
            activity?.let {
                ActivityCompat.requestPermissions(
                    it,
                    PERMISSIONS_STORAGE,
                    REQUEST_EXTERNAL_STORAGE
                )
            }
        }
    }

    private fun getPlatformVersion(result: Result) {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }

    fun callFlutterMethod(method: Method, arguments: Any?) {
        channel.invokeMethod(method.name, arguments)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity;
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {
        this.activity = null
    }
}

enum class Method {
    MERGE,
    ON_PROGRESS,
    ON_SUCCESS,
    REQUEST_EXTERNAL_STORAGE,
    GET_PLATFORM_VERSION
}


// Storage Permissions
private const val REQUEST_EXTERNAL_STORAGE = 1
private val PERMISSIONS_STORAGE = arrayOf(
    Manifest.permission.READ_EXTERNAL_STORAGE,
    Manifest.permission.WRITE_EXTERNAL_STORAGE,
)
