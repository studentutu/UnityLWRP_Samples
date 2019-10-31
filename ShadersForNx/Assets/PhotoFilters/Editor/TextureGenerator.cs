using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class TextureGenerator : EditorWindow
{
    [MenuItem("Window/Generate 3D Texture")]
    static void Init()
    {
        TextureGenerator window = (TextureGenerator)EditorWindow.GetWindow(typeof(TextureGenerator));
        window.Show();
    }

    void OnGUI()
    {
        if (GUILayout.Button("Open Folder"))
        {
            string path = EditorUtility.OpenFolderPanel("Load png or jpg Textures", "", "");
            string[] files = Directory.GetFiles(path);

            List<Texture2D> textures = new List<Texture2D>();

            foreach (string file in files)
            {
                if (file.EndsWith(".png") || file.EndsWith(".jpg"))
                {
                    var fileData = File.ReadAllBytes(file);
                    Texture2D texture = new Texture2D(2, 2);
                    texture.LoadImage(fileData);
                    textures.Add(texture);
                }
            }

            if (textures.Count > 0)
            {
                int sizeX = textures[0].width;
                int sizeY = textures[0].height;
                int sizeZ = textures.Count;
                List<Color> colorArray = new List<Color>();// = new Color[sizeX * sizeY * sizeZ];
                Texture3D texture3D = new Texture3D(sizeX, sizeY, sizeZ, TextureFormat.RGBA32, false);

                for (int z = 0; z < sizeZ; z++)
                {
                    colorArray.AddRange(textures[z].GetPixels());
                }

                texture3D.SetPixels(colorArray.ToArray());
                texture3D.Apply();

                AssetDatabase.CreateAsset(texture3D, "Assets/Texture3D.asset");
            }
        }
    }
}
