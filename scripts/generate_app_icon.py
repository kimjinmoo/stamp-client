import os
import math
from PIL import Image, ImageDraw, ImageFilter

def create_master_icon(size=1024):
    # Draw at 4x for ultra smooth antialiasing
    scale = 4
    w = size * scale
    h = size * scale

    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Background Rounded Rect with Gradient
    # Color 1: #FF5A5F (Top-Left) -> Color 2: #E81744 (Bottom-Right)
    radius = int(w * 0.22) # Apple / Material standard squircle curve
    mask = Image.new("L", (w, h), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, w, h], radius=radius, fill=255)

    gradient = Image.new("RGBA", (w, h))
    g_draw = ImageDraw.Draw(gradient)
    for y in range(h):
        ratio = y / h
        # Gradient from Coral Red (#FF5E62) to Deep Coral Crimson (#E62348)
        r = int(255 * (1 - ratio) + 230 * ratio)
        g = int(94 * (1 - ratio) + 35 * ratio)
        b = int(98 * (1 - ratio) + 72 * ratio)
        g_draw.line([(0, y), (w, y)], fill=(r, g, b, 255))

    img.paste(gradient, (0, 0), mask)

    # 2. Subtle ambient glow inside
    glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    cx, cy = w // 2, h // 2
    glow_draw.ellipse([cx - w*0.35, cy - h*0.35, cx + w*0.35, cy + h*0.35], fill=(255, 255, 255, 40))
    glow = glow.filter(ImageFilter.GaussianBlur(radius=scale * 40))
    img = Image.alpha_composite(img, glow)

    # 3. Outer Stamp Circle (White with decorative dash/dots)
    draw = ImageDraw.Draw(img)
    stamp_r = int(w * 0.36)
    
    # Outer white ring
    draw.ellipse([cx - stamp_r, cy - stamp_r, cx + stamp_r, cy + stamp_r], 
                 outline=(255, 255, 255, 240), width=scale * 14)
    
    # Notched / serrated decorative ring
    num_teeth = 36
    inner_teeth_r = stamp_r - scale * 26
    outer_teeth_r = stamp_r - scale * 12
    for i in range(num_teeth):
        angle = (2 * math.pi / num_teeth) * i
        dot_x = cx + math.cos(angle) * (stamp_r - scale * 20)
        dot_y = cy + math.sin(angle) * (stamp_r - scale * 20)
        dot_size = scale * 5
        draw.ellipse([dot_x - dot_size, dot_y - dot_size, dot_x + dot_size, dot_y + dot_size],
                     fill=(255, 255, 255, 220))

    # Inner circular disc (Pure White with subtle shadow)
    inner_disc_r = stamp_r - scale * 34
    draw.ellipse([cx - inner_disc_r, cy - inner_disc_r, cx + inner_disc_r, cy + inner_disc_r],
                 fill=(255, 255, 255, 255))

    # Inner mint circular badge
    mint_r = int(inner_disc_r * 0.85)
    # Mint Gradient: #00E5AA -> #00B887
    mint_img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    mint_draw = ImageDraw.Draw(mint_img)
    mint_draw.ellipse([cx - mint_r, cy - mint_r, cx + mint_r, cy + mint_r], fill=(0, 210, 157, 255))
    img = Image.alpha_composite(img, mint_img)

    # 4. Central Graphic: Dynamic Stylized Stamp with Checkmark & Golden Lightning
    draw = ImageDraw.Draw(img)

    # White Checkmark in Mint Circle
    # Checkmark coords
    check_pts = [
        (cx - scale * 85, cy + scale * 5),
        (cx - scale * 25, cy + scale * 65),
        (cx + scale * 95, cy - scale * 55)
    ]
    draw.line(check_pts, fill=(255, 255, 255, 255), width=scale * 28, joint="round")
    draw.ellipse([check_pts[0][0] - scale*14, check_pts[0][1] - scale*14, check_pts[0][0] + scale*14, check_pts[0][1] + scale*14], fill=(255, 255, 255, 255))
    draw.ellipse([check_pts[2][0] - scale*14, check_pts[2][1] - scale*14, check_pts[2][0] + scale*14, check_pts[2][1] + scale*14], fill=(255, 255, 255, 255))

    # 5. Overlapping Combo Energy Lightning Bolt (Top Right -> Center)
    # Golden Amber (#FFB300 / #FFA000) with White Border
    bolt_pts = [
        (cx + scale * 45, cy - scale * 170), # top tip
        (cx + scale * 10, cy - scale * 45),  # mid right
        (cx + scale * 60, cy - scale * 45),  # mid out
        (cx - scale * 15, cy + scale * 110), # bottom tip
        (cx + scale * 15, cy - scale * 5),   # mid left in
        (cx - scale * 35, cy - scale * 5),   # mid left
    ]
    # Draw white thick border for lightning
    draw.polygon(bolt_pts, fill=(255, 180, 0, 255), outline=(255, 255, 255, 255))
    # Line border around lightning for crispness
    for i in range(len(bolt_pts)):
        p1 = bolt_pts[i]
        p2 = bolt_pts[(i + 1) % len(bolt_pts)]
        draw.line([p1, p2], fill=(255, 255, 255, 255), width=scale * 12)

    # Redraw filled polygon to be clean
    draw.polygon(bolt_pts, fill=(255, 185, 0, 255))

    # 6. Small floating sparkle stars (Top-Left & Bottom-Right)
    def draw_star(sx, sy, star_size, color):
        pts = [
            (sx, sy - star_size),
            (sx + star_size * 0.28, sy - star_size * 0.28),
            (sx + star_size, sy),
            (sx + star_size * 0.28, sy + star_size * 0.28),
            (sx, sy + star_size),
            (sx - star_size * 0.28, sy + star_size * 0.28),
            (sx - star_size, sy),
            (sx - star_size * 0.28, sy - star_size * 0.28),
        ]
        draw.polygon(pts, fill=color)

    # Sparkles
    draw_star(cx - scale * 180, cy - scale * 140, scale * 32, (255, 255, 255, 240))
    draw_star(cx + scale * 200, cy + scale * 150, scale * 24, (255, 220, 100, 240))
    draw_star(cx - scale * 190, cy + scale * 160, scale * 20, (255, 255, 255, 200))

    # Downsample to target size with LANCZOS
    final_icon = img.resize((size, size), Image.Resampling.LANCZOS)
    return final_icon

def export_all_icons():
    master = create_master_icon(1024)
    
    # Ensure asset dirs exist
    os.makedirs("assets/icon", exist_ok=True)
    master.save("assets/icon/app_icon.png")
    print("Saved assets/icon/app_icon.png")

    # Android Mipmaps
    android_sizes = {
        "android/app/src/main/res/mipmap-mdpi/ic_launcher.png": 48,
        "android/app/src/main/res/mipmap-hdpi/ic_launcher.png": 72,
        "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png": 96,
        "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png": 144,
        "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png": 192,
    }
    for path, sz in android_sizes.items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        master.resize((sz, sz), Image.Resampling.LANCZOS).save(path)
        print(f"Saved {path} ({sz}x{sz})")

    # iOS AppIcons
    ios_sizes = {
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png": 1024,
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png": 20,
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png": 40,
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png": 60,
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png": 29,
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png": 58,
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png": 87,
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png": 40,
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png": 80,
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png": 120,
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png": 120,
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png": 180,
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png": 76,
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png": 152,
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png": 167,
    }
    for path, sz in ios_sizes.items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        master.resize((sz, sz), Image.Resampling.LANCZOS).save(path)
        print(f"Saved {path} ({sz}x{sz})")

if __name__ == "__main__":
    export_all_icons()
