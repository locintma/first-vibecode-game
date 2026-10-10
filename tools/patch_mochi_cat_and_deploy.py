#!/usr/bin/env python3
import os
import sys
import struct
import io
import math
import subprocess
from PIL import Image, ImageFilter

def make_ctex(image_rgba: Image.Image) -> bytes:
    """Converts a PIL RGBA image into a Godot 4 GST2 CompressedTexture2D (.ctex) binary."""
    w, h = image_rgba.size
    webp_buf = io.BytesIO()
    # Save lossless WebP
    image_rgba.save(webp_buf, format="WEBP", lossless=True)
    webp_bytes = webp_buf.getvalue()

    header = bytearray(56)
    # Magic GST2
    header[0:4] = b'GST2'
    struct.pack_into('<I', header, 4, 1)          # version = 1
    struct.pack_into('<I', header, 8, w)          # width
    struct.pack_into('<I', header, 12, h)         # height
    struct.pack_into('<I', header, 16, 0x0d000000)# format flags
    struct.pack_into('<I', header, 20, 0xffffffff)# flags
    # zero padding 24..35
    struct.pack_into('<I', header, 36, 2)         # internal mode
    struct.pack_into('<I', header, 40, 0x01000100)# dimension flags
    # zero padding 44..47
    struct.pack_into('<I', header, 48, 5)         # 5 = WebP
    struct.pack_into('<I', header, 52, len(webp_bytes)) # payload size

    return bytes(header) + webp_bytes

def render_all_poses():
    import bpy

    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene

    scene.render.engine = 'CYCLES'
    scene.cycles.device = 'CPU'
    scene.cycles.use_denoising = False
    scene.cycles.samples = 64
    scene.render.resolution_x = 256
    scene.render.resolution_y = 256
    scene.render.film_transparent = True
    scene.render.image_settings.color_mode = 'RGBA'

    # Camera setup (cozy orthographic angle)
    cam_data = bpy.data.cameras.new("CozyCamera")
    cam_data.type = 'ORTHO'
    cam_data.ortho_scale = 3.2
    cam_obj = bpy.data.objects.new("CozyCamera", cam_data)
    scene.collection.objects.link(cam_obj)
    scene.camera = cam_obj
    cam_obj.location = (0.0, -3.8, 1.6)
    cam_obj.rotation_euler = (math.radians(67.0), 0.0, 0.0)

    # Lighting setup (Golden sun + fill + rim + under-chin bounce)
    key_data = bpy.data.lights.new("KeyLight", type='AREA')
    key_data.energy = 260
    key_data.size = 2.2
    key_data.color = (1.0, 0.96, 0.90)
    key_obj = bpy.data.objects.new("KeyLight", key_data)
    scene.collection.objects.link(key_obj)
    key_obj.location = (2.2, -2.5, 3.0)
    key_obj.rotation_euler = (math.radians(45), math.radians(20), math.radians(35))

    fill_data = bpy.data.lights.new("FillLight", type='AREA')
    fill_data.energy = 110
    fill_data.size = 3.0
    fill_data.color = (0.88, 0.93, 1.0)
    fill_obj = bpy.data.objects.new("FillLight", fill_data)
    scene.collection.objects.link(fill_obj)
    fill_obj.location = (-2.5, -2.0, 1.6)

    rim_data = bpy.data.lights.new("RimLight", type='AREA')
    rim_data.energy = 220
    rim_data.size = 1.6
    rim_data.color = (1.0, 0.90, 0.75)
    rim_obj = bpy.data.objects.new("RimLight", rim_data)
    scene.collection.objects.link(rim_obj)
    rim_obj.location = (0.0, 2.5, 2.8)

    bounce_data = bpy.data.lights.new("BounceLight", type='AREA')
    bounce_data.energy = 160
    bounce_data.size = 2.0
    bounce_data.color = (1.0, 0.95, 0.88)
    bounce_obj = bpy.data.objects.new("BounceLight", bounce_data)
    scene.collection.objects.link(bounce_obj)
    bounce_obj.location = (0.0, -1.8, 0.3)
    bounce_obj.rotation_euler = (math.radians(-30), 0.0, 0.0)

    # Materials
    def make_material(name, color, roughness=0.32):
        mat = bpy.data.materials.new(name)
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes.get("Principled BSDF")
        if bsdf:
            bsdf.inputs['Base Color'].default_value = color
            bsdf.inputs['Roughness'].default_value = roughness
        return mat

    mat_body = make_material("MochiCream", (0.98, 0.95, 0.90, 1.0), roughness=0.30)
    mat_pink = make_material("EarPink", (0.97, 0.74, 0.72, 1.0), roughness=0.38)
    mat_eye = make_material("GlossEye", (0.10, 0.08, 0.08, 1.0), roughness=0.04)
    mat_eye_shine = make_material("EyeShine", (1.0, 1.0, 1.0, 1.0), roughness=0.08)
    mat_nose = make_material("CuteNose", (0.94, 0.52, 0.52, 1.0), roughness=0.25)
    mat_blush = make_material("BlushPink", (1.0, 0.68, 0.68, 1.0), roughness=0.45)
    mat_shadow = make_material("ShadowMat", (0.25, 0.18, 0.15, 0.22), roughness=0.95)

    def smooth_and_subsurf(obj, levels=2):
        for poly in obj.data.polygons:
            poly.use_smooth = True
        sub = obj.modifiers.new(name="Subsurf", type='SUBSURF')
        sub.levels = levels
        sub.render_levels = levels

    # Geometry
    bpy.ops.mesh.primitive_cylinder_add(radius=0.62, depth=0.005, location=(0, 0, 0.005))
    shadow_obj = bpy.context.active_object
    shadow_obj.name = "ContactShadow"
    shadow_obj.scale = (1.05, 0.72, 1.0)
    shadow_obj.data.materials.append(mat_shadow)

    bpy.ops.mesh.primitive_uv_sphere_add(segments=28, ring_count=18, radius=0.52, location=(0, 0.02, 0.44))
    body = bpy.context.active_object
    body.name = "Body"
    body.scale = (1.02, 0.92, 0.82)
    body.data.materials.append(mat_body)
    smooth_and_subsurf(body, 2)

    bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=22, radius=0.62, location=(0, -0.04, 1.02))
    head = bpy.context.active_object
    head.name = "Head"
    head.scale = (1.14, 0.98, 0.94)
    head.data.materials.append(mat_body)
    smooth_and_subsurf(head, 2)

    for side, x_mult in [("L", -1.0), ("R", 1.0)]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.22, depth=0.36, location=(x_mult * 0.38, -0.05, 1.56))
        ear = bpy.context.active_object
        ear.name = f"EarOuter_{side}"
        ear.rotation_euler = (math.radians(-6), math.radians(x_mult * -18), math.radians(x_mult * 10))
        ear.scale = (0.85, 0.40, 1.15)
        ear.data.materials.append(mat_body)
        smooth_and_subsurf(ear, 1)

        bpy.ops.mesh.primitive_cone_add(radius1=0.15, depth=0.26, location=(x_mult * 0.38, -0.12, 1.55))
        ear_in = bpy.context.active_object
        ear_in.name = f"EarInner_{side}"
        ear_in.rotation_euler = (math.radians(-6), math.radians(x_mult * -18), math.radians(x_mult * 10))
        ear_in.scale = (0.72, 0.28, 0.95)
        ear_in.data.materials.append(mat_pink)
        smooth_and_subsurf(ear_in, 1)

    for side, x_mult in [("L", -1.0), ("R", 1.0)]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.082, location=(x_mult * 0.25, -0.58, 1.02))
        eye = bpy.context.active_object
        eye.name = f"Eye_{side}"
        eye.scale = (0.95, 0.55, 1.15)
        eye.data.materials.append(mat_eye)
        smooth_and_subsurf(eye, 1)

        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.030, location=(x_mult * 0.22 + (x_mult * -0.016), -0.63, 1.07))
        shine1 = bpy.context.active_object
        shine1.name = f"EyeShine1_{side}"
        shine1.data.materials.append(mat_eye_shine)

        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.015, location=(x_mult * 0.28 + (x_mult * -0.016), -0.62, 0.98))
        shine2 = bpy.context.active_object
        shine2.name = f"EyeShine2_{side}"
        shine2.data.materials.append(mat_eye_shine)

        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.090, location=(x_mult * 0.42, -0.50, 0.89))
        blush = bpy.context.active_object
        blush.name = f"Blush_{side}"
        blush.scale = (1.05, 0.32, 0.65)
        blush.data.materials.append(mat_blush)
        smooth_and_subsurf(blush, 1)

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.032, location=(0.0, -0.63, 0.96))
    nose = bpy.context.active_object
    nose.name = "Nose"
    nose.scale = (1.25, 0.55, 0.85)
    nose.data.materials.append(mat_nose)
    smooth_and_subsurf(nose, 1)

    for side, x_mult in [("L", -1.0), ("R", 1.0)]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.14, location=(x_mult * 0.25, -0.36, 0.12))
        paw = bpy.context.active_object
        paw.name = f"Paw_{side}"
        paw.scale = (0.95, 1.3, 0.65)
        paw.data.materials.append(mat_body)
        smooth_and_subsurf(paw, 1)

    bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=0.44, location=(0.38, 0.28, 0.30))
    tail = bpy.context.active_object
    tail.name = "Tail"
    tail.rotation_euler = (math.radians(-25), math.radians(45), math.radians(55))
    tail.data.materials.append(mat_body)
    smooth_and_subsurf(tail, 1)

    raw_dir = "/tmp/mochi_cat_all_poses"
    os.makedirs(raw_dir, exist_ok=True)

    poses = {
        "idle_0":     {"head_z": 1.02, "body_s": (1.02, 0.92, 0.82), "body_z": 0.44, "shadow_s": 1.0, "eye_open": True},
        "idle_1":     {"head_z": 0.99, "body_s": (1.06, 0.96, 0.78), "body_z": 0.42, "shadow_s": 1.05, "eye_open": True},
        "idle_2":     {"head_z": 1.04, "body_s": (0.98, 0.88, 0.86), "body_z": 0.46, "shadow_s": 0.95, "eye_open": True},
        "hop_crouch": {"head_z": 0.86, "body_s": (1.18, 1.06, 0.64), "body_z": 0.35, "shadow_s": 1.15, "eye_open": True},
        "hop_air":    {"head_z": 1.25, "body_s": (0.88, 0.82, 1.05), "body_z": 0.68, "shadow_s": 0.70, "eye_open": True},
        "hop_land":   {"head_z": 0.92, "body_s": (1.14, 1.02, 0.72), "body_z": 0.38, "shadow_s": 1.10, "eye_open": True},
        "eat":        {"head_z": 0.98, "body_s": (1.08, 0.96, 0.80), "body_z": 0.43, "shadow_s": 1.0, "eye_open": True},
        "joy":        {"head_z": 1.12, "body_s": (0.94, 0.85, 0.94), "body_z": 0.52, "shadow_s": 0.85, "eye_open": False},
        "sleep":      {"head_z": 0.88, "body_s": (1.12, 1.04, 0.68), "body_z": 0.36, "shadow_s": 1.10, "eye_open": False},
    }

    for name, config in poses.items():
        head.location.z = config["head_z"]
        body.scale = config["body_s"]
        body.location.z = config["body_z"]
        shadow_obj.scale = (1.05 * config["shadow_s"], 0.72 * config["shadow_s"], 1.0)
        
        for side in ["L", "R"]:
            eye_obj = bpy.data.objects.get(f"Eye_{side}")
            shine1_obj = bpy.data.objects.get(f"EyeShine1_{side}")
            shine2_obj = bpy.data.objects.get(f"EyeShine2_{side}")
            if eye_obj:
                if not config["eye_open"]:
                    eye_obj.scale = (1.1, 0.2, 0.15)
                    if shine1_obj: shine1_obj.hide_render = True
                    if shine2_obj: shine2_obj.hide_render = True
                else:
                    eye_obj.scale = (0.95, 0.55, 1.15)
                    if shine1_obj: shine1_obj.hide_render = False
                    if shine2_obj: shine2_obj.hide_render = False

        render_path = os.path.join(raw_dir, f"{name}.png")
        scene.render.filepath = render_path
        bpy.ops.render.render(write_still=True)
        print(f"Rendered: {name}")

    return raw_dir

def build_cozy_assets(raw_dir):
    """Processes rendered images into individual 256x256 frames and a 1024x1024 sprite sheet."""
    clean_frames = {}
    
    # 1. Process and smooth each rendered frame
    for fname in os.listdir(raw_dir):
        if not fname.endswith(".png"): continue
        pose = fname[:-4]
        p = os.path.join(raw_dir, fname)
        im = Image.open(p).convert("RGBA")
        r, g, b, a = im.split()
        rgb = Image.merge('RGB', (r, g, b))
        rgb_smooth = rgb.filter(ImageFilter.SMOOTH)
        smoothed = Image.merge('RGBA', (*rgb_smooth.split(), a))
        clean_frames[pose] = smoothed

    # 2. Map of CTEX files in clean unpack
    ctex_map = {
        "eat": "eat.png-9ceb5263d308190fe5bac6ff53778a2c.ctex",
        "hop_air": "hop_air.png-561be5b1989462afcec9ee2413cd70cd.ctex",
        "hop_crouch": "hop_crouch.png-419341f49d46129e3dba54c05f64294d.ctex",
        "hop_land": "hop_land.png-d4373c48ab4d746a856131b469c4e573.ctex",
        "idle_0": "idle_0.png-7e1b9089fe85ce9030d32058ccc0e619.ctex",
        "idle_1": "idle_1.png-dc48d239c4654479f1a01a2691cd9f10.ctex",
        "idle_2": "idle_2.png-d6b4db4fb0c144b95ea936aaf7a03aeb.ctex",
        "joy": "joy.png-678ef1169a11167fdfcde5923976e5e7.ctex",
        "sleep": "sleep.png-44958bc7cbb6e930a5c0694ed47f0622.ctex",
    }

    imported_dir = "/tmp/cozy_clean/.godot/imported"

    # Write each individual 256x256 CTEX
    for pose, ctex_name in ctex_map.items():
        if pose in clean_frames:
            frame_256 = clean_frames[pose].resize((256, 256), Image.Resampling.LANCZOS)
            ctex_bytes = make_ctex(frame_256)
            out_ctex_path = os.path.join(imported_dir, ctex_name)
            with open(out_ctex_path, "wb") as f:
                f.write(ctex_bytes)
            print(f"Patched CTEX: {out_ctex_path} ({len(ctex_bytes)} bytes)")

    # Also update mochi_cat.png (the 256x256 catalog portrait)
    portrait_ctex = os.path.join(imported_dir, "mochi_cat.png-3be7d98d7883c87babc76daed83a1f63.ctex")
    portrait_img = clean_frames["idle_0"].resize((256, 256), Image.Resampling.LANCZOS)
    with open(portrait_ctex, "wb") as f:
        f.write(make_ctex(portrait_img))
    print(f"Patched Catalog Portrait CTEX: {portrait_ctex}")

    # Build the 1024x1024 3x3 Sprite Sheet
    # Layout:
    # row 0: idle_0 (0,0), idle_1 (341,0), idle_2 (682,0)
    # row 1: hop_crouch (0,341), hop_air (341,341), hop_land (682,341)
    # row 2: eat (0,682), joy (341,682), sleep (682,682)
    sheet = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    grid = [
        ("idle_0", 0, 0),
        ("idle_1", 341, 0),
        ("idle_2", 682, 0),
        ("hop_crouch", 0, 341),
        ("hop_air", 341, 341),
        ("hop_land", 682, 341),
        ("eat", 0, 682),
        ("joy", 341, 682),
        ("sleep", 682, 682),
    ]

    for pose, gx, gy in grid:
        if pose in clean_frames:
            cell_img = clean_frames[pose].resize((341, 341), Image.Resampling.LANCZOS)
            sheet.paste(cell_img, (gx, gy), cell_img)

    sheet_ctex = os.path.join(imported_dir, "mochi_cat_sheet.png-bacea1847c21314916b3957726694d03.ctex")
    with open(sheet_ctex, "wb") as f:
        f.write(make_ctex(sheet))
    print(f"Patched 1024x1024 Sheet CTEX: {sheet_ctex}")

    # Also save PNG preview copies
    sheet.save("/tmp/new_mochi_cat_sheet.png")
    portrait_img.save("/tmp/new_mochi_cat_portrait.png")

if __name__ == "__main__":
    if "--render" in sys.argv:
        raw_dir = render_all_poses()
    else:
        raw_dir = "/tmp/mochi_cat_all_poses"
        if not os.path.exists(raw_dir):
            raw_dir = render_all_poses()
    build_cozy_assets(raw_dir)
