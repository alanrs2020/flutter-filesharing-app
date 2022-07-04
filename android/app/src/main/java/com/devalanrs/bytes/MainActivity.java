package com.devalanrs.bytes;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Environment;
import android.os.ParcelFileDescriptor;
import android.provider.MediaStore;
import android.util.Log;
import android.util.Size;
import android.webkit.MimeTypeMap;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.documentfile.provider.DocumentFile;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "storage_access";
    private static final int CREATE_FILE = 44;
    private static final String TAG = "dgs";
    private static final int OPEN_FOLDER = 55;
    private static Dialog dialog;
    //HashMap<String,String> hashMap = new HashMap<String, String>();
    @SuppressLint("ResourceType")

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
                GeneratedPluginRegistrant.registerWith(flutterEngine);


        dialog = new Dialog(this);
        // TODO: Register the ListTileNativeAdFactory
//        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "listTile",
//                new ListTileNativeAdFactory(getContext()));

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "Save":
                                   String fileName = call.argument("name");
                                   String fileUri = call.argument("uri");
                                   try {
                                    File directory = new File(GetPath(this)+"/Bytes");
                                    //System.out.println(directory.getPath());
                                    if (!directory.mkdir()){
                                        boolean v = directory.mkdir();
                                        System.out.println("Folder created"+v);
                                    }else { }
                                    System.out.println(directory.getPath());
                                    DocumentFile pickedDir = DocumentFile.fromFile(directory);
                                    DocumentFile subDir = pickedDir.createDirectory("bytes Received");
                                    DocumentFile file = subDir.createFile("*/*",  fileName);


                                    Intent mediaScannerIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
                                    Uri fileContentUri = file.getUri();
                                    mediaScannerIntent.setData(fileContentUri);
                                    sendBroadcast(mediaScannerIntent);

                                       ParcelFileDescriptor pfd =
                                               this.getContentResolver().
                                                       openFileDescriptor(file.getUri(), "rw");

                                           FileOutputStream fileOutputStream =
                                                   new FileOutputStream(pfd.getFileDescriptor());

                                           InputStream in = this.getContentResolver().openInputStream(Uri.parse(fileUri));
                                           byte[] buf = new byte[in.available()];
                                           int len;
                                           while((len=in.read(buf))>0){
                                               fileOutputStream.write(buf,0,len);
                                           }

                                           fileOutputStream.close();
                                           pfd.close();
                                           this.getContentResolver().delete(Uri.parse(fileUri), null, null);

                                       } catch (IOException e) {
                                           e.printStackTrace();
                                       }
                                    break;
                                case "isFolderExits":
                                   boolean isExit = true;
                                   result.success(isExit);

                                    break;
                                case "AppFolder":
                                    String path = this.getFilesDir().getAbsolutePath();
                                    result.success(path);

                                    break;
                                case "AppFiles":
                                    HashMap<String, String> paths = getFiles(this);
                                    result.success(paths);
                                    break;
                                case "getThumb":
                                   byte[] bitmap = getThumbnail(call.argument("path"));
                                    result.success(bitmap);
                                    break;
                                case "savePDF":
                                    byte[] bytes = call.argument("bytes");
                                    String name = call.argument("name");
                                    Runnable r = new SavePdf(bytes,name,getApplicationContext());
                                    new Thread(r).start();
                                    result.success(true);
                                    break;
                                case "getCacheFolder":
                                    File _path =  getExternalCacheDir().getAbsoluteFile();
                                    result.success(_path);
                                case "getIp":
                                    WifiManager wifiMgr = (WifiManager) getApplicationContext().getSystemService(WIFI_SERVICE);
                                    WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
                                    int ip = wifiInfo.getIpAddress();
                                    //String ipAddress = Formatter.formatIpAddress(ip);
                                    String ipAddress = getIPAddress(true);
                                    result.success(ipAddress);
                                case "getDocuments":


                                   // HashMap<Integer, Object> hashMap = getDocuments();


                                  //  result.success(hashMap);

                                 default:
                                     Log.e("f","Error");
                                     break;
                            }
                        }
                );
    }

    private static String getMimeType2(String url) {
        String type = "none";
        String extension = MimeTypeMap.getFileExtensionFromUrl(url);
        if (extension != null) {
            type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
        }
        if (type != null){
            return type;
        }else{
            return "none";
        }

    }
    private static String getIPAddress(boolean useIPv4) {
        try {
            ArrayList<NetworkInterface> interfaces = Collections.list(NetworkInterface.getNetworkInterfaces());
            for (NetworkInterface intf : interfaces) {
                ArrayList<InetAddress> addrs = Collections.list(intf.getInetAddresses());
                for (InetAddress addr : addrs) {
                    if (!addr.isLoopbackAddress()) {
                        String sAddr = addr.getHostAddress();
                        //boolean isIPv4 = InetAddressUtils.isIPv4Address(sAddr);
                        boolean isIPv4 = sAddr.indexOf(':')<0;

                        if (useIPv4) {
                            if (isIPv4)
                                return sAddr;
                        } else {
                            if (!isIPv4) {
                                int delim = sAddr.indexOf('%'); // drop ip6 zone suffix
                                return delim<0 ? sAddr.toUpperCase() : sAddr.substring(0, delim).toUpperCase();
                            }
                        }
                    }
                }
            }
        } catch (Exception ignored) { } // for now eat exceptions
        return "";
    }









    byte[] getThumbnail(String path){
        try{
            Uri uri = Uri.fromFile(new File(path));
            String type = getMimeType(uri);
            System.out.println(type);
           if (type.contains("image")){
               Bitmap bitmap = MediaStore.Images.Media.getBitmap(this.getActivity().getContentResolver(), uri);
               Bitmap thumbBitmap = ThumbnailUtils.extractThumbnail(bitmap,96,96);
               // imageView.setImageBitmap(thumbBitmap);
               ByteArrayOutputStream stream = new ByteArrayOutputStream();
               thumbBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
               byte[] byteArray = stream.toByteArray();
               thumbBitmap.recycle();
               return byteArray;
           }else if (type.contains("video")){

               Bitmap thumbBitmap = ThumbnailUtils.createVideoThumbnail(path,
                       MediaStore.Video.Thumbnails.MICRO_KIND);
               // imageView.setImageBitmap(thumbBitmap);
               ByteArrayOutputStream stream = new ByteArrayOutputStream();
               thumbBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
               byte[] byteArray = stream.toByteArray();
               thumbBitmap.recycle();
               return byteArray;
           }else if(type.contains("audio")){
                Bitmap thumbBitmap = null;
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                    thumbBitmap = ThumbnailUtils.createAudioThumbnail(new File(path),
                            new Size(50,50),null);
                }else {
                    return null;
                }
                // imageView.setImageBitmap(thumbBitmap);
               ByteArrayOutputStream stream = new ByteArrayOutputStream();
               thumbBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
               byte[] byteArray = stream.toByteArray();
               thumbBitmap.recycle();
               return byteArray;
           }else{
               return null;
           }
        }
        catch (IOException ex){
            //......
            return null;
        }

    }
    public String getMimeType(Uri uri) {
        String mimeType = null;
        if (ContentResolver.SCHEME_CONTENT.equals(uri.getScheme())) {
            ContentResolver cr = getApplicationContext().getContentResolver();
            mimeType = cr.getType(uri);
        } else {
            String fileExtension = MimeTypeMap.getFileExtensionFromUrl(uri
                    .toString());
            mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(
                    fileExtension.toLowerCase());
        }
        return mimeType;
    }


    HashMap<String,String> getFiles(Context context) {
        try {
            HashMap<String,String> map = new HashMap<>();
            File[] folders1;
            File path = new  File(GetPath(context)+"/Bytes/bytes Received");
            if (path.isDirectory()) {
                folders1 = path.listFiles();

                for (int i = 0; i < folders1.length; i++) {

                    map.put("name" + i, folders1[i].getName());
                    map.put("path" + i, folders1[i].getAbsolutePath());

                }
            }
            System.out.println(map.values());
            return map;
        }catch (Exception e){
            System.out.println("Error"+e);
            return null;
        }
    }

    @Override
    public void cleanUpFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine);

        // TODO: Unregister the ListTileNativeAdFactory
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile");
    }
    public void showToast(String msg){
        Toast.makeText(getApplicationContext(), msg, Toast.LENGTH_SHORT).show();
    }
    public class SavePdf implements Runnable{
        private final byte[] bytes;
        private final String filename;
        private final Context context;
        public SavePdf(byte[] bytes, String filename,Context context){
            this.bytes = bytes;
            this.filename = filename;
            this.context = context;
        }
        @Override
        public void run() {


                    try {
                           File directory = new File(GetPath(context)+"/Bytes");
                           System.out.println(directory.getPath());
                           if (!directory.mkdir()){
                               boolean v = directory.mkdir();
                               System.out.println("Folder created"+v);
                           }else { }
                           System.out.println(directory.getPath());
                           DocumentFile pickedDir = DocumentFile.fromFile(directory);
                           DocumentFile subDir = pickedDir.createDirectory("bytes PDFScanner");
                           DocumentFile file = subDir.createFile("*/*",  filename);


                           Intent mediaScannerIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
                           Uri fileContentUri = file.getUri();
                           mediaScannerIntent.setData(fileContentUri);
                           sendBroadcast(mediaScannerIntent);


                           ParcelFileDescriptor pfd =
                                   context.getContentResolver().
                                           openFileDescriptor(file.getUri(), "rw");

                           FileOutputStream fos =
                                   new FileOutputStream(pfd.getFileDescriptor());

                           fos.write(bytes);
                           fos.flush();
                           fos.close();

                    }catch (Exception e){
                        Log.e("Save PDF", String.valueOf(e));
                    }
            }

    }

    String GetPath(Context context){
        if ((android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)){
            return context.getExternalMediaDirs()[0].toString();
        }else {
            return Environment.getExternalStorageDirectory().getAbsolutePath();
        }
    }
}

class Storage extends Thread {

}