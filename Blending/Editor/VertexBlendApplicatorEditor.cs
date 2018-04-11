using UnityEngine;
using UnityEditor;
using bTools.CodeExtensions;
using System;

namespace bTools.Shaders
{
    [CustomEditor(typeof(VertexBlendApplicator))]
    public class VertexBlendApplicatorEditor : Editor
    {
        // Paint settings
        public Color paintColor;
        public float maxRadius;
        public bool onMesh;
        public RaycastHit lastHit;
        public Vector4 texCoord3 = new Vector4(1, 1, 0, 1);
        public Color[] colorSwatches = new Color[] { Color.white, Color.black, Color.red, Color.green, Color.blue };

        // Paint modes
        private static bool displayVertices = true;
        private static bool shouldDoBrush = false;
        private static bool doColorBrush;
        private static bool doHeightBrush;
        private static bool doFalloffBrush;

        private VertexBlendApplicator blendee;

        private void OnEnable()
        {
            blendee = (VertexBlendApplicator)target;
            Undo.undoRedoPerformed += OnUndoRedo;
            maxRadius = EditorPrefs.GetFloat("SuperBlend.MaxBrushRadius", 1.0f);
        }

        private void OnDisable()
        {
            Tools.hidden = false;
            EditorPrefs.SetFloat("SuperBlend.MaxBrushRadius", maxRadius);
        }

        public override void OnInspectorGUI()
        {
            #region Init
            blendee = (VertexBlendApplicator)target;
            #endregion

            #region Brush Settings
            GUILayout.Space(4);
            shouldDoBrush = EditorGUILayout.ToggleLeft("Enable (Tab)", shouldDoBrush);
            displayVertices = EditorGUILayout.ToggleLeft("Display Vertices", displayVertices);
            maxRadius = EditorGUILayout.FloatField("Radius", maxRadius);
            maxRadius = Mathf.Abs(maxRadius);
            #endregion

            GUILayout.Space(8);

            doColorBrush = EditorGUILayout.ToggleLeft("Do Color", doColorBrush, (GUIStyle)"ShurikenModuleTitle");
            if (doColorBrush)
            {
                GUILayout.Space(4);
                paintColor = EditorGUILayout.ColorField("Color", paintColor);

                Rect colorShortcuts = EditorGUILayout.GetControlRect();
                Rect swatch = colorShortcuts;
                swatch.x += (colorShortcuts.width / 2);
                swatch.width = 20;
                swatch.height = 20;

                for (int i = 0; i < colorSwatches.Length; i++)
                {
                    EditorGUI.DrawRect(swatch, Colors.BlackChocolate);
                    EditorGUI.DrawRect(swatch.WithPadding(4), colorSwatches[i]);
                    if (EditorGUIExtensions.RightClickOnRect(swatch))
                    {
                        paintColor = colorSwatches[i];
                        Repaint();
                    }

                    swatch.x = swatch.xMax + 2;
                }

                GUILayout.Space(8);
            }

            doHeightBrush = EditorGUILayout.ToggleLeft("Do Height", doHeightBrush, (GUIStyle)"ShurikenModuleTitle");
            if (doHeightBrush)
            {
                GUILayout.Space(4);
                texCoord3.z = EditorGUILayout.Slider("Height", texCoord3.z, -1, 1);
                GUILayout.Space(8);
            }

            doFalloffBrush = EditorGUILayout.ToggleLeft("Do Falloff", doFalloffBrush, (GUIStyle)"ShurikenModuleTitle");
            if (doFalloffBrush)
            {
                GUILayout.Space(4);
                texCoord3.w = EditorGUILayout.Slider("Falloff", texCoord3.w, 0.001f, 1);
                GUILayout.Space(8);
            }
        }

        private void OnSceneGUI()
        {
            var current = Event.current;
            if (current.type == EventType.KeyDown && current.keyCode == KeyCode.Tab)
            {
                Repaint();
                shouldDoBrush = !shouldDoBrush;
            }

            Tools.hidden = false;
            if (!shouldDoBrush) return;
            if (GUIUtility.hotControl != 0) return;

            HandleUtility.AddDefaultControl(GUIUtility.GetControlID(GUIUtility.GetControlID("SuperBlend".GetHashCode(), FocusType.Keyboard), FocusType.Keyboard));
            Tools.hidden = true;

            Ray ray = HandleUtility.GUIPointToWorldRay(Event.current.mousePosition);

            // Update brush
            if (RXLookingGlass.IntersectRayMesh(ray, blendee.meshFilter, out lastHit))
            {
                Handles.CircleHandleCap(0, lastHit.point, Quaternion.LookRotation(lastHit.normal, Vector3.up), maxRadius, EventType.Repaint);
                onMesh = true;
            }
            else
            {
                onMesh = false;
            }

            if (onMesh && current.modifiers == EventModifiers.None)
            {
                VertexEditFlags useFlags = VertexEditFlags.None;
                int vertCount = blendee.cachedPos.Count;

                for (int i = 0; i < vertCount; i++)
                {
                    Vector3 worldSpacePos = blendee.transform.TransformPoint(blendee.cachedPos[i]);
                    Vector3 vertToMouse = worldSpacePos - lastHit.point;

                    if (maxRadius >= vertToMouse.magnitude)
                    {
                        // Repaint vert indicators
                        if (displayVertices && current.type == EventType.Repaint)
                        {
                            Handles.color = blendee.cachedColors[i].WithAlpha(1);
                            Handles.CubeHandleCap(0, worldSpacePos, Quaternion.identity, HandleUtility.GetHandleSize(worldSpacePos) * 0.05f, EventType.Repaint);
                        }

                        // Handle click
                        if ((current.type == EventType.MouseDown || current.type == EventType.MouseDrag) && current.button == 0)
                        {
                            Undo.RecordObject(blendee, "Edited Mesh");

                            if (doColorBrush)
                            {
                                blendee.cachedColors[i] = paintColor;
                                useFlags |= VertexEditFlags.Color;
                            }

                            if (doHeightBrush)
                            {
                                Vector4 copy = blendee.cachedUV3[i];
                                copy.z = texCoord3.z;
                                blendee.cachedUV3[i] = copy;

                                useFlags |= VertexEditFlags.UV3;
                            }

                            if (doFalloffBrush)
                            {
                                Vector4 copy = blendee.cachedUV3[i];
                                copy.w = texCoord3.w;
                                blendee.cachedUV3[i] = copy;

                                useFlags |= VertexEditFlags.UV3;
                            }
                        }
                    }
                }// end for each vertex

                if (useFlags != 0)
                {
                    current.Use();
                    blendee.ApplyCache(useFlags);
                }
            }
        }

        void OnUndoRedo()
        {
            //blendee.UpdateCache();
            blendee.ApplyCache((VertexEditFlags)int.MaxValue);
            SceneView.RepaintAll();
        }
    }
}