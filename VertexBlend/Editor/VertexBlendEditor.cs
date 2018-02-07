using UnityEngine;
using UnityEditor;
using bTools.CodeExtensions;
using System;

[CustomEditor(typeof(VertexBlendApplicator))]
public class VertexBlendEditor : Editor
{
    [SerializeField] PaintBrush brush = new PaintBrush();
    VertexBlendApplicator blendee;

    // Paint modes
    private static bool shouldDoBrush = false;
    private static bool doColorBrush;
    private static bool doHeightBrush;
    private static bool doFalloffBrush;

    // Paint settings
    public Color paintColor;
    public Vector4 texCoord3 = new Vector4(1, 1, 0, 1);
    public Color[] colorSwatches = new Color[] { Color.white, Color.black, Color.red, Color.green, Color.blue };

    // Extra
    bool showExtra;

    private void OnEnable()
    {
        blendee = (VertexBlendApplicator)target;
        Undo.undoRedoPerformed += OnUndoRedo;
    }

    private void OnDisable()
    {
        Tools.hidden = false;
    }

    void OnUndoRedo()
    {
        blendee.UpdateCache();
        blendee.ApplyCache((VertexBlendApplicator.VertexEditFlags)int.MaxValue);
        SceneView.RepaintAll();
    }

    public override void OnInspectorGUI()
    {
        #region Init
        blendee = (VertexBlendApplicator)target;
        #endregion

        #region Brush Settings
        GUILayout.Space(4);
        shouldDoBrush = EditorGUILayout.ToggleLeft("Enable (Tab)", shouldDoBrush);
        brush.maxRadius = EditorGUILayout.FloatField("Radius", brush.maxRadius);
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

        showExtra = EditorGUILayout.ToggleLeft("Extras", showExtra, (GUIStyle)"ShurikenModuleTitle");
        if (showExtra)
        {
            GUILayout.Space(4);
            if (GUILayout.Button("Post-Lightmapping Fix ", EditorStyles.miniButton))
            {
                blendee.FixStream();
            }
            if (GUILayout.Button("Save into new mesh", EditorStyles.miniButton))
            {
                blendee.SaveMeshToAsset();
            }
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

        RenderBrush();

        if (brush.onMesh && current.modifiers == EventModifiers.None)
        {
            VertexBlendApplicator.VertexEditFlags useFlags = VertexBlendApplicator.VertexEditFlags.None;

            for (int i = 0; i < blendee.cachedPos.Count; i++)
            {
                if (VertexInRange(i))
                {
                    Handles.color = blendee.cachedColors[i].WithAlpha(1);
                    Vector3 worldSpacePos = blendee.transform.TransformPoint(blendee.cachedPos[i]);
                    Handles.CubeHandleCap(0, worldSpacePos, Quaternion.identity, HandleUtility.GetHandleSize(worldSpacePos) * 0.05f, EventType.Repaint);

                    if ((current.type == EventType.MouseDown || current.type == EventType.MouseDrag) && current.button == 0)
                    {
                        if (doColorBrush)
                        {
                            blendee.cachedColors[i] = paintColor;
                            useFlags |= VertexBlendApplicator.VertexEditFlags.Color;
                        }

                        if (doHeightBrush)
                        {
                            Vector4 copy = blendee.cachedUV3[i];
                            copy.z = texCoord3.z;
                            blendee.cachedUV3[i] = copy;

                            useFlags |= VertexBlendApplicator.VertexEditFlags.UV3;
                        }

                        if (doFalloffBrush)
                        {
                            Vector4 copy = blendee.cachedUV3[i];
                            copy.w = texCoord3.w;
                            blendee.cachedUV3[i] = copy;

                            useFlags |= VertexBlendApplicator.VertexEditFlags.UV3;
                        }
                    }
                }
            }

            if (useFlags != 0)
            {
                current.Use();
                blendee.ApplyCache(useFlags);
            }
        }
    }

    void RenderBrush()
    {
        Ray ray = HandleUtility.GUIPointToWorldRay(Event.current.mousePosition);

        if (Physics.Raycast(ray, out brush.lastHit, Mathf.Infinity, Physics.AllLayers, QueryTriggerInteraction.Ignore))
        {
            Handles.CircleHandleCap(0, brush.lastHit.point, Quaternion.LookRotation(brush.lastHit.normal, Vector3.up), brush.maxRadius, EventType.Repaint);
            Handles.CircleHandleCap(0, brush.lastHit.point, Quaternion.LookRotation(brush.lastHit.normal, Vector3.up), brush.maxRadius * brush.falloffRadius, EventType.Repaint);
            brush.onMesh = true;
        }
        else
        {
            brush.onMesh = false;
        }
    }

    bool VertexInRange(int vertIndex)
    {
        return Mathf.Abs(Vector3.Distance(blendee.transform.TransformPoint(blendee.cachedPos[vertIndex]), brush.lastHit.point)) <= brush.maxRadius;
    }

    [Serializable]
    class PaintBrush
    {
        public float maxRadius
        {
            get
            {
                return EditorPrefs.GetFloat("SuperBlend.MaxBrushRadius", 1.0f);
            }
            set
            {
                EditorPrefs.SetFloat("SuperBlend.MaxBrushRadius", value);
            }
        }
        public float falloffRadius
        {
            get
            {
                return EditorPrefs.GetFloat("SuperBlend.BrushFalloff", 0.80f);
            }
            set
            {
                EditorPrefs.SetFloat("SuperBlend.BrushFalloff", value);
            }
        }

        public bool onMesh;
        public RaycastHit lastHit;
    }
}