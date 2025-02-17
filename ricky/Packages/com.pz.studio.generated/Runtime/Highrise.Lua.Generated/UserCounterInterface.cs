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
    [AddComponentMenu("Lua/UserCounterInterface")]
    [LuaBehaviourScript(s_scriptGUID)]
    public class UserCounterInterface : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "56903f4a80c943c4892d8692579f3bb8";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public System.String m_counterMessage = "Unique Users";

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), null),
                CreateSerializedProperty(_script.GetPropertyAt(1), m_counterMessage),
            };
        }
    }
}

#endif
