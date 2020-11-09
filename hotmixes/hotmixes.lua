local function write_hotmixes()
    local lfs = require 'lfs_ffi'
    local template = require "resty.template"

    local request_uri = ngx.var.request_uri
    request_uri = ngx.unescape_uri(request_uri)

    local request_path
    if request_uri ~= '/' then
        request_path = request_uri .. '/'
    else
        request_path = request_uri
    end

    local data_dir = '/mnt/mixes'
    local data_path = data_dir .. request_path

    -- we want to know if something is an image
    local function match_image( file )
        local filext = file:match("[^.]+$")
        local extensions = {jpg=true, jpeg=true, png=true, gif=true}

        if extensions[filext:lower()] then
            return true
        else
            return false
        end
    end

    -- we want to know if something is an video file
    local function match_video( file )
        local filext = file:match("[^.]+$")
        local extensions = {mp4=true}

        if extensions[filext:lower()] then
            return true
        else
            return false
        end
    end

    local function scandir(directory)
        local i, t, popen = 0, {}, io.popen
        local pfile = popen('ls "'..directory..'" -I "*.filepart"')
        for filename in pfile:lines() do
            i = i + 1
            t[i] = filename
        end
        pfile:close()
        return t
    end

    local function latest_files(directory)
        local i, t, popen = 0, {}, io.popen
        local pfile = popen('find "'..directory..'" -type f ! -name \'*.filepart\' -printf \'%C@ %p\n\'| sort -n -r | head -10 | cut -f2- -d" "| sed s:"'..directory..'/"::')
        for filename in pfile:lines() do
            i = i + 1
            t[i] = filename
        end
        pfile:close()
        return t
    end

    local function these_files( path )
        local files, dirs, images = {}, {}, {}
        -- lfs.dir() doesn't work, so we use this function to list contents of a data_path

        for i, file in ipairs( scandir( path ) ) do
            if lfs.attributes( path .. file,"mode" ) == "file" then
                if match_image( file ) then
                    table.insert( images, file )
                else
                    table.insert( files, file )
                end
            elseif lfs.attributes( path .. file,"mode" ) == "directory" then
                table.insert( dirs, file )
            end
        end
        local stuff = {
            files = files,
            dirs = dirs,
            images = images
        }
        return stuff
    end

    local function these_latest()
        -- list last 10 modified files in our directory
        local latest_path, latest_name = {}, {}

        for i, file_path in ipairs( latest_files( data_dir ) ) do
            table.insert( latest_path, file_path )

            local temp = ""
            local result = ""
            for i = file_path:len(), 1, -1 do
                if file_path:sub(i,i) ~= "/" then
                    temp = temp..file_path:sub(i,i)
                else
                    break
                end
            end

            for j = temp:len(), 1, -1 do
                result = result..temp:sub(j,j)
            end

            table.insert( latest_name, result )
        end

        return latest_path, latest_name
    end

    local path_uri = '/mixes' .. request_path

    local function total_files_dir( path )
        local i, t, popen = 0, {}, io.popen
        local pfile = popen('find "'..path..'" -type f | wc -l')
        for total in pfile:lines() do
            t[i] = total
            i = i + 1
        end
        pfile:close()
        return t
    end

    local latest_path, latest_name = these_latest()

    if request_uri == '/latest.xml' then
        template.render("latest.xml", {
            local_total = total_files_dir( data_dir ),
            local_latestpath = latest_path,
            local_latestname = latest_name
        })
    elseif request_uri == '/' then
        local stuff = these_files( data_path )
        template.render("viewroot.html", {
            local_total = total_files_dir( data_dir ),
            local_uri = request_path,
            local_path = path_uri,
            local_dirs = stuff["dirs"],
            local_images = stuff["images"],
            local_latestpath = latest_path,
            local_latestname = latest_name,
            match_video = match_video
        })
    else
        local stuff = these_files( data_path )
        template.render("view.html", {
            local_total = total_files_dir( data_dir ),
            local_uri = request_path,
            local_path = path_uri,
            local_files = stuff["files"],
            local_dirs = stuff["dirs"],
            local_images = stuff["images"],
            local_latestpath = latest_path,
            local_latestname = latest_name,
            match_video = match_video
        })
    end
end

return write_hotmixes
