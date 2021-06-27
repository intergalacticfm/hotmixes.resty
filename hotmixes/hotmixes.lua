local function write_hotmixes()
    local lfs = require 'lfs_ffi'
    local template = require "resty.template"

    local request_uri = ngx.var.request_uri
    request_uri = ngx.unescape_uri(request_uri)
    ngx.log(ngx.ERR, request_uri)

    if string.find(request_uri, "\"") or string.find(request_uri, "%`") or string.find(request_uri, "%$") then
        ngx.log(ngx.ERR, "Illegal request_uri")
        ngx.exit(500)
    end

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

    local function latest_files(directory)
        local i, t, popen = 0, {}, io.popen
        local pfile = popen('find "' .. directory .. '" -type f ! -name \'*.filepart\' -printf \'%C@ %p\n\'| sort -nr | head -7 | cut -f2- -d" "| sed s:"' .. directory .. '/"::')
        for filename in pfile:lines() do
            i = i + 1
            t[i] = filename
        end
        pfile:close()
        return t
    end

    local function search_files(directory, searchString)
        local i, filenames, popen = 0, {}, io.popen
        local pfile = popen('find "' .. directory .. '" -type f -name \'*' .. searchString .. '*.mp3\' -printf \'%C@ %p\n\'| sort -nr | head -7 | cut -f2- -d" "| sed s:"' .. directory .. '/"::')

        for filename in pfile:lines() do
            i = i + 1
            filenames[i] = filename
        end
        pfile:close()
        return filenames
    end

    local function these_files(path)
        local files, dirs, images = {}, {}, {}
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." and not string.match(file, ".filepart") then
                if lfs.attributes(path .. file, "mode") == "file" then
                    if match_image( file ) then
                        table.insert( images, file )
                    else
                        table.insert( files, file )
                    end
                elseif lfs.attributes( path .. file, "mode" ) == "directory" then
                    table.insert( dirs, file )
                end
            end
        end

        table.sort( images )
        table.sort( files )
        table.sort( dirs )

        local stuff = {
            files = files,
            dirs = dirs,
            images = images
        }
        return stuff
    end

    local function these_search(directory, request)
        local files, dirs, images = {}, {}, {}
        local i, t, popen = 0, {}, io.popen
        local searchString = string.match(request, "/search/(.*)")
        ngx.log(ngx.ERR, "search: " .. string.match(request, "/search/(.*)"))
        local pfile = popen('find "' .. directory .. '" -type f -iname \'*' .. searchString .. '*.mp3\' -printf \'%C@ %p\n\'| sort -nr | head -7 | cut -f2- -d" "| sed s:"' .. directory .. '/"::')

        for file in pfile:lines() do
            ngx.log(ngx.ERR, "file: " .. file)

            --if file ~= "." and file ~= ".." and not string.match(file, ".filepart") then
            --    if lfs.attributes( path .. file, "mode" ) == "file" then
            --        if match_image( file ) then
            --            table.insert( images, file )
            --        else
            --            table.insert( files, file )
            --        end
            --    elseif lfs.attributes( path .. file, "mode" ) == "directory" then
            --        table.insert( dirs, file )
            --    end
            --end
        end
        pfile:close()

        table.sort(images)
        table.sort(files)
        table.sort(dirs)

        local stuff = {
            files = files,
            dirs = dirs,
            images = images
        }
        return stuff
    end

    local function these_latest()
        -- list last 7 modified files in our directory
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

    local function starts_with(str, start)
        return str:sub(1, #start) == start
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
    ngx.log(ngx.ERR, "request_uri: " .. request_uri)

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
            local_latestname = latest_name
        })
    elseif starts_with(request_uri,  '/search') then
        local stuff = these_search(data_dir, request_uri)
        template.render("viewsearch.html", {
            local_total = total_files_dir( data_dir ),
            local_uri = request_path,
            local_path = path_uri,
            local_dirs = stuff["dirs"],
            local_images = stuff["images"],
            local_latestpath = latest_path,
            local_latestname = latest_name
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
            local_latestname = latest_name
        })
    end


end


return write_hotmixes
