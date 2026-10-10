extends SceneTree

func _init():
    var packer = PCKPacker.new()
    var target_pck = "/tmp/cozy_fetched/index.pck"
    var base_dir = "/tmp/cozy_clean"
    
    var err = packer.pck_start(target_pck, 32)
    if err != OK:
        print("Failed to start PCK: ", err)
        quit(1)
        return
        
    var files = []
    _collect_files(base_dir, base_dir, files)
    print("Found files to pack: ", files.size())
    
    for f in files:
        var res_path = "res://" + f
        var src_path = base_dir.path_join(f)
        err = packer.add_file(res_path, src_path)
        if err != OK:
            print("Failed to add ", res_path, ": ", err)
            
    err = packer.flush()
    print("Packed successfully with status: ", err)
    quit(0)

func _collect_files(current_dir: String, root_dir: String, out_files: Array):
    var dir = DirAccess.open(current_dir)
    if not dir:
        return
    dir.include_hidden = true
    dir.include_navigational = false
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        var full_path = current_dir.path_join(file_name)
        if dir.current_is_dir():
            _collect_files(full_path, root_dir, out_files)
        else:
            var rel = full_path.substr(root_dir.length() + 1)
            out_files.append(rel)
        file_name = dir.get_next()
