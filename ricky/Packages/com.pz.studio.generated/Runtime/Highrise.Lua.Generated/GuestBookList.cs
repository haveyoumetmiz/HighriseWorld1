/*

    Copyright (c) 2024 Pocketz World. All rights reserved.

    This is a generated file, do not edit!

    Generated by com.pz.studio
*/

#if UNITY_EDITOR

using System;
using System.Linq;
using UnityEngine;
using Highrise.Client;

namespace Highrise.Lua.Generated
{
    [AddComponentMenu("Lua/GuestBookList")]
    [LuaBehaviourScript(s_scriptGUID)]
    public class GuestBookList : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "dd0241337ff76b349b980152ffb9faea";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public System.String m_Title = "Guest Book";
        [SerializeField] public System.String m_CloseButtonText = "Close";
        [SerializeField] public System.Double m_MaxGuests = 15;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_Title),
                CreateSerializedProperty(_script.GetPropertyAt(1), m_CloseButtonText),
                CreateSerializedProperty(_script.GetPropertyAt(2), m_MaxGuests),
                CreateSerializedProperty(_script.GetPropertyAt(3), null),
                CreateSerializedProperty(_script.GetPropertyAt(4), null),
                CreateSerializedProperty(_script.GetPropertyAt(5), null),
                CreateSerializedProperty(_script.GetPropertyAt(6), null),
            };
        }
    }
}

#endif
