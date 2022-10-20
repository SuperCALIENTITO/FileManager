-----------------------------------
-------- File Manager Core --------
-----------------------------------

local FM = {}
FM.root = "file_manager"
FM.cache = ""
FM.cmds = {
    ["append"] = true,
    ["asyncread"] = true,
    ["createdir"] = true,
    ["delete"] = true,
    ["exists"] = true,
    ["find"] = true,
    ["isdir"] = true,
    ["open"] = true,
    ["read"] = true,
    ["rename"] = true,
    ["size"] = true,
    ["time"] = true,
    ["write"] = true
}
FM.paths = {
    ["GAME"] = true,
    ["LUA"] = true,
    ["lcl"] = true,
    ["lsv"] = true,
    ["LuaMenu"] = true,
    ["DATA"] = true,
    ["DOWNLOAD"] = true,
    ["MOD"] = true,
    ["BASE_PATH"] = true,
    ["EXECUTABLE_PATH"] = true,
    ["THIRDPARTY"] = true,
    ["WORKSHOP"] = true,
    ["BSP"] = true,
}
FM.langK = {
    ["en"] = true,
    ["es"] = true,
}
FM.cmdsK = {}
for i, _ in pairs(FM.cmds) do table.insert(FM.cmdsK, i) end
CreateConVar("file_lang", "en", {FCVAR_ARCHIVE}, "Select the language of the file system")

-----------------------------------
------------- Language ------------
-----------------------------------

FM.lang = {

    ["en"] = {
        ["ins_args"]        = "insufficient arguments",

        ["file_exists"]     = "file already exists",
        ["file_no_exists"]  = "file doesn't exists",
        ["file_invalid"]    = "file isn't valid or doesn't exists",
        ["file_created"]    = "file successful created",
        ["file_removed"]    = "file successful removed",

        ["dir_exists"]      = "directory already exists",
        ["dir_no_exists"]   = "directory doesn't exists",
        ["dir_invalid"]     = "directory isn't valid or doesn't exists",
        ["dir_created"]     = "directory successful created",
        ["dir_removed"]     = "directory successful removed",
    
        ["gamepath_no_exists"]  = "the specified gamepath is not valid",
        ["file_dir_not_found"]  = "file/dir not found",
        ["file_dir_found"]      = "file/dir found!",

        ["append_success"] = "file appened successful: ",
    },

    ["es"] = {
        ["ins_args"] = "argumentos insuficientes",

        ["file_exists"]     = "el archivo ya existe",
        ["file_no_exists"]  = "el archivo no existe",
        ["file_invalid"]    = "el archivo es invalido o no existe",
        ["file_created"]    = "archivo creado con exito",
        ["file_removed"]    = "archivo eliminado con exito",

        ["dir_exists"]      = "el directorio existe",
        ["dir_no_exists"]   = "el directorio no existe",
        ["dir_invalid"]     = "el directorio es invalido o no existe",
        ["dir_created"]     = "directorio creado con exito",
        ["dir_removed"]     = "directorio eliminado con exito",
    
        ["gamepath_no_exists"]  = "el Gamepath especificado no es valido",
        ["file_dir_not_found"]  = "archivo/directorio no encontrado",
        ["file_dir_found"]      = "archivo/directorio encontrado!",

        ["append_success"] = "file appened successful: ",
    }
}

local function L(v, ...)
    return FM.lang[GetConVar("file_lang"):GetString()][v] or FM.lang["en"][v]
end

-----------------------------------
------------ Functions ------------
-----------------------------------
FM.func = {

    ------------------
    ----- Append -----
    ------------------
    ["append"] = function(name, content)
        if not ( name and content ) then
            return L"ins_args"
        end

        if not file.Exists(name, "DATA") then
            return L"file_no_exists"
        end

        file.Append(name, content)

        return L"append_success" .. content
    end,

    ------------------
    ---- AsyncRead ---
    ------------------
    ["asyncread"] = function(filename, gamepath)
        if not filename then
            return L"ins_args"
        end

        if not FM.paths[gamepath] then
            return L"gamepath_no_exists"
        end

        local aStatus, aData = "", ""
        file.AsyncRead(filename, gamepath, function(fName, gPath, status, data)
            if ( status == FSASYNC_OK ) then
                aStatus = status
                aData = data
            else
                aStatus = status
            end
        end)

        return aStatus, aData
    end,

    ------------------
    ---- CreateDir ---
    ------------------
    ["createdir"] = function(name, global)
        local dir = FM.root .. "/"
        if global then
            dir = ""
        end

        dir = dir .. name

        if file.IsDir(dir, "DATA") then
            return L"dir_exists"
        end

        file.CreateDir(dir)
        return L"dir_created"
    end,

    ------------------
    ----- Delete -----
    ------------------
    ["delete"] = function(name, global)
        local dir = FM.root .. "/"
        if global then
            dir = ""
        end

        dir = dir .. name

        if not file.Exists(dir, "DATA") then
            return L"file_invalid"
        end

        if file.IsDir(dir, "DATA") then
            file.Delete(dir)
            return L"dir_removed"
        end

        file.Delete(dir)
        return L"file_removed"
    end,

    ------------------
    ------ Find ------
    ------------------
    ["exists"] = function(name, gamepath)

        if not gamepath then
            gamepath = "DATA"
        end

        if not FM.paths[gamepath] then
            return L"gamepath_no_exists"
        end

        return file.Exists(name, gamepath) and L"file_dir_found" or L"file_dir_not_found"
        
    end,

    ------------------
    ------ Find ------
    ------------------
}

-----------------------------------
------------- Commands ------------
-----------------------------------

function FM.Init()
    return file.IsDir(FM.root, "DATA") or file.CreateDir(FM.root)
end

function FM.command(_, cmd, args, argStr)
    local aCmd = args[1]
    local a1, a2, a3, a4 = args[2],args[3],args[4],args[5]

    if FM.cmds[aCmd] then

        print(FM.func[aCmd](a1, a2, a3, a4))

    end
end

function FM.autoComplete(cmd, args)
    local t = {}

    for _, cmds in pairs(FM.cmdsK) do
        table.insert(t, cmd .. " " .. cmds)
    end

    return t
end

concommand.Add("file", FM.command, FM.autoComplete)
FM.Init()