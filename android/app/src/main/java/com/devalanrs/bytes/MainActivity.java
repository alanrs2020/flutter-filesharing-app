package com.devalanrs.bytes;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Dialog;
import android.content.ActivityNotFoundException;
import android.content.ClipData;
import android.content.Context;
import android.content.Intent;
import android.content.UriPermission;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.os.ParcelFileDescriptor;
import android.provider.DocumentsContract;
import android.text.format.DateFormat;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.documentfile.provider.DocumentFile;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "storage_access";
    private static final int CREATE_FILE = 44;
    private static final String TAG = "dgs";
    private static final int OPEN_FOLDER = 55;
    private static Dialog dialog;
    private final ViewDialog alert = new ViewDialog();
    HashMap<String,String> hashMap = new HashMap<String, String>();
    @SuppressLint("ResourceType")
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        dialog = new Dialog(this);
        // TODO: Register the ListTileNativeAdFactory
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "listTile",
                new ListTileNativeAdFactory(getContext()));

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "SaveFile":
                                    byte[] file = call.argument("file");
                                    String filename = call.argument("name");
                                    saveFile(file,filename);
                                    //Toast.makeText(this, "Created File", Toast.LENGTH_SHORT).show();
                                    break;
                                case "isFolderExits":
                                   boolean isExit = isFolder();
                                   result.success(isExit);

                                    break;
                                case "savePDF":
                                    byte[] bytes = call.argument("bytes");
                                    String name = call.argument("name");
                                    Runnable r = new SavePdf(bytes,name,getApplicationContext());
                                    new Thread(r).start();
                                    result.success(true);
                                    break;
                                case "getFolders":
                                    getFolderPath();
                                    result.success(hashMap);
                                    break;
                                case "CreateFolder":
                                    CreateFolder();
                                    result.success(true);
                                    break;
                                case "OpenFolder":
                                    String path = call.argument("Path");
                                    OpenFolder(path);
                                    break;
                                case "AppFolder":
                                   String uri = getAppFolder();
                                   result.success(uri);
                                    break;
                                 default:
                                     Log.e("f","Error");
                                     break;
                            }
                        }
                );
    }


    private String getAppFolder() {
       File path = getFilesDir();
       if (path != null){
           return path.getAbsolutePath();
       }else {
           return null;
       }
    }

    private void OpenFolder(String path){


        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.N){

            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.setDataAndType(Uri.parse(path), "*/*");
            try {
                startActivity(intent);
            }
            catch (ActivityNotFoundException e) {
                Log.e("Not Supported",e.toString());
            }


        } else{
            Uri uri = Uri.parse(Uri.decode("file://"+path.trim()));
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.setDataAndType(uri, "*/*");
            try {
                startActivity(intent);
            }
            catch (ActivityNotFoundException e) {
                Log.e("Error Not Supported",e.toString());
            }

        }

    }
    private HashMap getFolderPath(){
        List<UriPermission> permissions = getContentResolver().getPersistedUriPermissions();
        if (permissions != null && permissions.size() > 0) {
            DocumentFile pickedDir = DocumentFile.fromTreeUri(this, permissions.get(0).getUri());
            if (pickedDir == null){
                return null;
            }else {
                DocumentFile newDir =  pickedDir.findFile("bytes Received");
                DocumentFile newDir2 =  pickedDir.findFile("bytes Documents");
                if (newDir == null && newDir2 == null){
                    return null;
                }else{
                    Log.i(TAG, "isFolder: Folder exit");
                    hashMap.put("Name0","bytes Received");
                    hashMap.put("Path0",newDir.getUri().toString());
                    hashMap.put("Name1","bytes Documents");
                    hashMap.put("Path1",newDir2.getUri().toString());
                    return hashMap;
                }
            }

        } else {
            return  null;
        }
    }

    public void CreateFolder(){

        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
        intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        intent.addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION);
        startActivityForResult(intent,CREATE_FILE);
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == CREATE_FILE && resultCode == Activity.RESULT_OK){
            Toast.makeText(this, "Folder Created", Toast.LENGTH_SHORT).show();
            Uri uri = null;
            if (data != null){
                dialog.dismiss();
                uri = data.getData();
                DocumentFile pickedDir = DocumentFile.fromTreeUri(this, uri);
                assert pickedDir != null;
                if (pickedDir.findFile("bytes Received") == null){
                    pickedDir.createDirectory("bytes Received");
                }else {
                    getContentResolver().takePersistableUriPermission(uri,Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                }
                if(pickedDir.findFile("bytes Documents") == null){
                    pickedDir.createDirectory("bytes Documents");
                }else {
                    getContentResolver().takePersistableUriPermission(uri,Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                }

            }
        }else if (requestCode == Activity.RESULT_CANCELED){
                Toast.makeText(this, "Selection Cancelled", Toast.LENGTH_SHORT).show();
            }
        }

    @Override
    public void cleanUpFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine);

        // TODO: Unregister the ListTileNativeAdFactory
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile");
    }

    public void  CreateFile(Uri uri, byte[] bytes){
        try {
            ParcelFileDescriptor pfd =
                    this.getContentResolver().
                            openFileDescriptor(uri, "w");

            FileOutputStream fileOutputStream =
                    new FileOutputStream(pfd.getFileDescriptor());



            fileOutputStream.write(bytes);
            fileOutputStream.close();
            pfd.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }



    public boolean isFolder(){
        List<UriPermission> permissions = getContentResolver().getPersistedUriPermissions();
        if (permissions != null && permissions.size() > 0) {
            DocumentFile pickedDir = DocumentFile.fromTreeUri(this, permissions.get(0).getUri());
            if (pickedDir == null){
                return false;
            }else {
                DocumentFile newDir =  pickedDir.findFile("bytes Received");
                DocumentFile newDir2 =  pickedDir.findFile("bytes Documents");
                if (newDir == null && newDir2 == null){
                    return false;
                }else{
                    Log.i(TAG, "isFolder: Folder exit");
                    return true;
                }
            }

        } else {
            return  false;
        }
    }
    public void saveFile(byte[] bytes, String filename) {


        List<UriPermission> permissions = getContentResolver().getPersistedUriPermissions();
        if (permissions != null && permissions.size() > 0) {

            DocumentFile pickedDir = DocumentFile.fromTreeUri(this, permissions.get(0).getUri());
            if (pickedDir.exists()){
                DocumentFile newDir =  pickedDir.findFile("bytes Received");
                if (newDir != null){
                    DocumentFile file = newDir.createFile("*/*",  filename);
                    CreateFile(file.getUri(), bytes);
                }else{
                    newDir =  pickedDir.createDirectory("bytes Received");
                    DocumentFile file = newDir.createFile("*/*",  filename);
                    CreateFile(file.getUri(), bytes);
                }
               //Toast.makeText(getApplicationContext(), "Successfully Saved", Toast.LENGTH_SHORT).show();

            }else
            {
                alert.showDialog(getActivity(), "You need to create a folder or select one.");
                dialog.show();

            }

        } else {
            alert.showDialog(getActivity(), "You need to create a folder or select one.");
            dialog.show();
        }
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
                    List<UriPermission> permissions = getContentResolver().getPersistedUriPermissions();
                    if (permissions != null && permissions.size() > 0) {

                        DocumentFile pickedDir = DocumentFile.fromTreeUri(getApplicationContext(), permissions.get(0).getUri());
                        assert pickedDir != null;
                        if (pickedDir.exists()){
                            DocumentFile newDir =  pickedDir.findFile("bytes Documents");
                            if (newDir != null){
                                DocumentFile file = newDir.createFile("*/*",  filename);
                                assert file != null;
                                CreateFile(file.getUri(), bytes);

                            }else{
                                newDir =  pickedDir.createDirectory("bytes Documents");
                                assert newDir != null;
                                DocumentFile file = newDir.createFile("*/*",  filename);
                                assert file != null;
                                CreateFile(file.getUri(),bytes);

                            }

                        }else
                        {
                            alert.showDialog(getActivity(), "You need to create a folder or select one.");
                            dialog.show();

                        }

                    } else {
                        alert.showDialog(getActivity(), "You need to create a folder or select one.");
                        dialog.show();
                    }
                }catch (Exception e){
                    Log.e("Save PDF", String.valueOf(e));
                }
            }

    }

    public class ViewDialog {

        public void showDialog(Activity activity, String msg){

            dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
            dialog.setCancelable(false);
            dialog.setContentView(R.layout.customview);

            TextView text = (TextView) dialog.findViewById(R.id.text_dialog);
            text.setText(msg);

            Button dialogButton = (Button) dialog.findViewById(R.id.btn_dialog);
            dialogButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                   // dialog.dismiss();
                    CreateFolder();
                }
            });

        }
    }
}
