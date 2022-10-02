using GmmlPatcher;
using UndertaleModLib;
using UndertaleModLib.Models;
using UndertaleModLib.Decompiler;
using GmmlHooker;
using TSIMPH;

namespace WYSMultiplayer
{
    public class GameMakerMod : IGameMakerMod
    {
        // from snailax source
        public static Dictionary<string, string> GMLkvp = new Dictionary<string, string>();

        public static GlobalDecompileContext? GDC;

        public static bool LoadGMLFolder(string gmlfolder)
        {
            return GMLkvp.LoadGMLFolder(gmlfolder);
        }

        public static UndertaleScript CreateScriptFromKVP(UndertaleData data, string name, string key, ushort arguments)
        {
            return data.CreateLegacyScript(name, GMLkvp[key], arguments);
        }

        // my code
        public void Load(int audioGroup, UndertaleData data, ModData currentMod)
        {
            if (audioGroup != 0) return;
            GDC = new GlobalDecompileContext(data, false);
            //supress vs being stupid (i mean he's not wrong)
            string gmlfolder = Path.Combine(currentMod.path, "GMLSource");

            LoadGMLFolder(gmlfolder);
            LoadGMLFolder(Path.Combine(gmlfolder, "apis"));
            LoadGMLFolder(Path.Combine(gmlfolder, "gamemodes"));

            UndertaleGameObject mp_player_obj = new UndertaleGameObject();

            mp_player_obj.Name = data.Strings.MakeString("obj_mp_player");

            mp_player_obj.Sprite = data.Sprites.ByName("spr_player");
            mp_player_obj.Persistent = true;

            mp_player_obj.EventHandlerFor(EventType.Create, data.Strings, data.Code, data.CodeLocals)
                .AppendGmlSafe(GMLkvp["gml_Object_obj_mp_player_Create"], data);

            mp_player_obj.EventHandlerFor(EventType.Other, EventSubtypeOther.User0, data.Strings, data.Code, data.CodeLocals)
                .AppendGmlSafe(GMLkvp["gml_Object_obj_mp_player_Other_10"], data);

            data.Code.ByName("gml_Object_obj_snaili_eye_Other_10").ReplaceGmlSafe(GMLkvp["gml_Object_obj_snaili_eye_Other_10"], data);
            data.Code.ByName("gml_Object_obj_ball_Step_1").ReplaceGmlSafe(GMLkvp["gml_Object_obj_ball_Step_1"], data);
            data.Code.ByName("gml_Object_obj_simple_hat_Other_10").ReplaceGmlSafe(GMLkvp["gml_Object_obj_simple_hat_Other_10"], data);
            data.Code.ByName("gml_GlobalScript_scr_spawn_correct_hat").ReplaceGmlSafe(GMLkvp["gml_GlobalScript_scr_spawn_correct_hat"], data);
            data.Code.ByName("gml_Object_obj_player_Create_0").ReplaceGmlSafe(GMLkvp["gml_Object_obj_player_Create_0"], data);

            mp_player_obj.EventHandlerFor(EventType.Step, EventSubtypeStep.Step, data.Strings, data.Code, data.CodeLocals)
                .AppendGmlSafe(GMLkvp["gml_Object_obj_mp_player_Step_0"], data);

            mp_player_obj.EventHandlerFor(EventType.Draw, EventSubtypeDraw.Draw, data.Strings, data.Code, data.CodeLocals)
                .AppendGmlSafe(GMLkvp["gml_Object_obj_mp_player_Draw_0"], data);

            data.GameObjects.Add(mp_player_obj);

            UndertaleGameObject multiplayermanager_obj = new UndertaleGameObject();

            multiplayermanager_obj.Name = data.Strings.MakeString("obj_multiplayer_manager");
            multiplayermanager_obj.Persistent = true;

            multiplayermanager_obj.EventHandlerFor(EventType.Step, EventSubtypeStep.Step, data.Strings, data.Code, data.CodeLocals)
                .AppendGmlSafe(GMLkvp["gml_obj_multiplayer_manager_Step_0"], data);
            multiplayermanager_obj.EventHandlerFor(EventType.Other, EventSubtypeOther.AsyncNetworking, data.Strings, data.Code, data.CodeLocals)
                .AppendGmlSafe(GMLkvp["gml_obj_multiplayer_manager_Network"], data);

            data.GameObjects.Add(multiplayermanager_obj);

            CreateScriptFromKVP(data, "scr_send_position", "gml_Script_scr_send_position", 6);

            CreateScriptFromKVP(data, "scr_send_player_info", "gml_Script_scr_send_player_info", 5);

            CreateScriptFromKVP(data, "scr_recived_packet", "gml_Script_scr_recived_packet", 2);

            CreateScriptFromKVP(data, "scr_player_join", "gml_Script_scr_player_join", 1);

            CreateScriptFromKVP(data, "scr_host_lpick", "gml_Script_scr_host_lpick", 0);

            CreateScriptFromKVP(data, "scr_player_add_team", "gml_Script_scr_player_add_team", 3);

            CreateScriptFromKVP(data, "scr_player_is_on_team", "gml_Script_scr_player_is_on_team", 2);

            CreateScriptFromKVP(data, "scr_player_remove_team", "gml_Script_scr_player_remove_team", 3);

            CreateScriptFromKVP(data, "scr_register_packet", "gml_Script_scr_register_packet", 1);

            CreateScriptFromKVP(data, "scr_send_packet", "gml_Script_scr_send_packet", 17);

            CreateScriptFromKVP(data, "scr_write_data", "gml_Script_scr_write_data", 17);

            CreateScriptFromKVP(data, "scr_mp_disconnect", "gml_Script_scr_mp_disconnect", 0);

            Conviences.ReplaceBuiltInFunction("scr_mp_fade_to_room_ext", "gml_Script_scr_fade_to_room_ext", GMLkvp["gml_Script_scr_mp_fade_to_room_ext"], 2, data);

            data.CreateCode("gml_RoomCC_room_multiplayer_Create", GMLkvp["gml_RoomCC_room_multiplayer_Create"]);

            try
            {
                data.Code.First(code => code.Name.Content == "gml_Object_obj_epilepsy_warning_Create_0")
                    .AppendGML("txt_1 = \"WORKS\"\ntxt_2 = \"The fitness gram pacer test is \na multi stage arobic capacity test.", data);
            }
            // UndertaleModLib is trying to write profile cache but fails, we don't care (i dont care more)
            catch (Exception) { }

            UndertaleRoom mp_room = Conviences.CreateBlankLevelRoom("room_multiplayer", data);

            mp_room.SetupRoom(false);

            mp_room.AddObjectToLayer(data, "obj_multiplayer_manager", "Player");

            mp_room.AddObjectToLayer(data, "obj_player", "Player");

            mp_room.AddObjectToLayer(data, "obj_dontRestartLevelOnDifficultyChange", "FadeOutIn");

            mp_room.AddObjectToLayer(data, "obj_post_processing_draw", "PostProcessing");

            var bottomWall = mp_room.AddObjectToLayer(data, "obj_wall", "Walls");

            bottomWall.Y = 900;
            bottomWall.ScaleX = 35;

            mp_room.CreationCodeId = data.Code.ByName("gml_RoomCC_room_multiplayer_Create");

            mp_room.SetupRoom(false);

            data.Rooms.Add(mp_room);

            UndertaleRoom levelselect = data.Rooms.First(room => room.Name.Content == "level_select");

            UndertaleRoom.GameObject gameobj = levelselect.GameObjects.First(obj => obj.ObjectDefinition.Name.Content == "obj_player");

            UndertaleRoom mp_basketball = Conviences.CreateBlankLevelRoom("mp_basketball", data);

            mp_basketball.SetupRoom(false);

            var player = mp_basketball.AddObjectToLayer(data, "obj_player", "Player");

            player.Y = 990;
            player.X = 90;

            mp_basketball.AddObjectToLayer(data, "obj_dontRestartLevelOnDifficultyChange", "FadeOutIn").X = -180;
            mp_basketball.AddObjectToLayer(data, "obj_dark_level", "FadeOutIn").X = -180;
            mp_basketball.AddObjectToLayer(data, "obj_music_bubble_gum", "FadeOutIn").X = -180; // maybe obj_music_helpy
            mp_basketball.AddObjectToLayer(data, "obj_no_squid_in_this_level", "FadeOutIn").X = -180;

            mp_basketball.AddObjectToLayer(data, "obj_post_processing_draw", "PostProcessing").X = -180;

            var ball = mp_basketball.AddObjectToLayer(data, "obj_ball", "MiniGames");

            ball.Y = 1080 - (60 * 3);
            ball.X = 1920 / 2;

            var basket = mp_basketball.AddObjectToLayer(data, "obj_basket", "Traps");

            basket.Y = 1080 - (60 * 8);
            basket.X = (60 * 2);

            basket = mp_basketball.AddObjectToLayer(data, "obj_basket", "Traps");

            basket.Y = 1080 - (60 * 8);
            basket.X = 1920 - (60 * 2);

            var wall = mp_basketball.AddObjectToLayer(data, "obj_wall", "Walls");
            wall.ScaleY = 17;

            wall = mp_basketball.AddObjectToLayer(data, "obj_wall", "Walls");

            wall.X = 1860;
            wall.ScaleY = 17;

            var floor = mp_basketball.AddObjectToLayer(data, "obj_wall", "Walls");

            floor.Y = 1020;
            floor.ScaleX = 32;

            mp_room.CreationCodeId = data.Code.ByName("gml_RoomCC_room_multiplayer_Create");

            mp_basketball.SetupRoom(false);

            data.Rooms.Add(mp_basketball);

            UndertaleRoom.GameObject portal = levelselect.AddObjectToLayer(data,"obj_level_select_portal","Goal");

            portal.X = gameobj.X + (60 * 150);
            portal.Y = gameobj.Y - 180;

            portal.CreationCode = data.CreateCode("gml_ObjectCC_obj_level_select_portal_Create",GMLkvp["gml_ObjectCC_obj_level_select_portal_Create"],0);

            UndertaleRoom.GameObject volleyball = levelselect.AddObjectToLayer(data, "obj_level_select_portal", "Goal");

            volleyball.X = portal.X + 60;
            volleyball.Y = portal.Y;

            volleyball.CreationCode = data.CreateCode("gml_ObjectCC_obj_level_select_portal_2_Create", GMLkvp["gml_ObjectCC_obj_level_select_portal_2_Create"], 0);

            UndertaleCode code = data.Code.First(c => c.Name.Content == "gml_Object_obj_snaili_eye_Draw_0");
            if (code != null)
            {
                Conviences.PrependCode("gml_Object_obj_snaili_eye_Draw_0", "if (!variable_instance_exists(id, \"dir\"))\nreturn false; ", data);
            }

            data.HookCode("gml_Object_obj_menu_MAIN_Other_10", @"#orig#()
if (variable_global_exists(""isHost""))
{
    ds_list_add(liMenuItemNames, ""Disconnect"")
    ds_list_add(liMenuItemInstances, -1)
    ds_list_add(liMenuItemScripts, scr_mp_disconnect)
    ds_list_add(liMenuItemScriptArguments, -1)
    ds_list_add(liMenuItemTooltipScript, -1)
    ds_list_add(liMenuItemTooltipArgument, -1)
}
");

            try
            { // vk_ralt, vk_rcontrol
                data.Code.First(code => code.Name.Content == "gml_Object_obj_player_Step_0")
                    .AppendGmlSafe(@"
if keyboard_check_pressed(vk_f5) && !variable_global_exists(""isHost"")
{
    global.justReset = false
    scr_fade_to_room(room_multiplayer)
}
if (variable_global_exists(""isHost"")) {
    if keyboard_check_pressed(vk_f6) && global.isHost
        scr_host_lpick();
}

if (variable_global_exists(""justReset""))
{
    if (global.justReset)
    {
        if keyboard_check_pressed(vk_f5) && variable_global_exists(""isHost"")
        {
            room_goto(room_multiplayer)
        }
    }
}
", data);
            } // vk_f5, vk_f6
            catch (Exception) { }
        }
    }
    
}
