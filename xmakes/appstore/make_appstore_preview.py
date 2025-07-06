from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import os
import platform
import textwrap
import json
from typing import List, Tuple, Optional
from dataclasses import dataclass
from fonts import FontManager

@dataclass
class DeviceConfig:
    filename: str
    text: str
    phone_y_offset: int
    text_y_offset: int
    background_image: str
    fastlane_device_identifier: str
    scale_factor: float
    font_size_title: int
    font_size_body: int
    fallback_font_path: Optional[str] = None

class AppStorePreviewGenerator:
    
    
    def __init__(self, language: str = "ko", device_type: str = "iphone"):
        self.resources_path = Path(__file__).parent / "resources" / "plots"
        self.fonts_path = Path(__file__).parent / "resources" / "fonts"
        self.default_font = ImageFont.load_default()
        self.language = language
        self.device_type = device_type
        
        # Load device-specific settings first
        self._load_device_settings_from_config()
        
        # Initialize font manager
        self.font_manager = FontManager(
            fonts_path=self.fonts_path,
            language=self.language,
            font_size_title=self.font_size_title,
            font_size_body=self.font_size_body
        )
        
        # Load fonts
        self.font_manager.load_fonts()
        
        self.device_configs = self._load_device_configs()
    

    
    def _load_device_settings_from_config(self):
        config_path = Path(__file__).parent / "resources" / "config" / "plots_config.json"
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                config_data = json.load(f)
            
            device_settings = config_data.get("devices", {}).get(self.device_type, {})
            self.phone_y_offset = device_settings.get("phone_y_offset", 180)
            self.text_y_offset = device_settings.get("text_y_offset", -120)
            self.background_image_name = device_settings.get("background_image", "iphone_background.jpg")
            self.fastlane_device_identifier = device_settings.get("fastlane_device_identifier", "")
            self.scale_factor = device_settings.get("scale_factor", 0.8)
            self.font_size_title = device_settings.get("font_size_title", 100)
            self.font_size_body = device_settings.get("font_size_body", 32)
            self.fallback_font_path = device_settings.get("fallback_font_path", None)

        except FileNotFoundError:
            print(f"Error: Config file not found: {config_path}")
            # Set default values if config not found
            self.phone_y_offset = 180
            self.text_y_offset = -120
            self.background_image_name = "iphone_background.jpg"
            self.fastlane_device_identifier = ""
            self.scale_factor = 0.8
            self.font_size_title = 100
            self.font_size_body = 32
        except Exception as e:
            print(f"Error loading device settings from config file: {e}")
            # Set default values on error
            self.phone_y_offset = 180
            self.text_y_offset = -120
            self.background_image_name = "iphone_background.jpg"
            self.fastlane_device_identifier = ""
            self.scale_factor = 0.8
            self.font_size_title = 100
            self.font_size_body = 32

    def _load_device_configs(self) -> List[DeviceConfig]:
        config_path = Path(__file__).parent / "resources" / "config" / "plots_config.json"
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                config_data = json.load(f)
            
            device_settings = config_data.get("devices", {}).get(self.device_type, {})
            image_filenames = [item['filename'] for item in device_settings.get('screenshots', [])]

            localized_texts_data = config_data.get('localization', {})
            localized_texts = localized_texts_data.get(self.language, {}).get('screenshot_texts', [])
            
            if not localized_texts:
                print(f"Warning: No localized texts found for language '{self.language}'. Using 'ko' as fallback.")
                localized_texts = localized_texts_data.get("ko", {}).get('screenshot_texts', [])

        except FileNotFoundError:
            print(f"Error: Config file not found: {config_path}")
            return []
        except Exception as e:
            print(f"Error loading config file: {e}")
            return []

        device_configs = []
        for i, filename in enumerate(image_filenames):
            text = localized_texts[i] if i < len(localized_texts) else ""
            device_configs.append(DeviceConfig(
                filename=filename,
                text=text,
                phone_y_offset=self.phone_y_offset,
                text_y_offset=self.text_y_offset,
                background_image=self.background_image_name,
                fastlane_device_identifier=self.fastlane_device_identifier,
                scale_factor=self.scale_factor,
                font_size_title=self.font_size_title,
                font_size_body=self.font_size_body,
                fallback_font_path=self.fallback_font_path
            ))
        
        print(f"Screenshot config loaded: {len(device_configs)} items (Language: {self.language}, Device: {self.device_type})")
        return device_configs
    
    def _load_background_image(self) -> Image.Image:
        bg_path = self.resources_path / self.background_image_name
        if bg_path.exists():
            return Image.open(bg_path).convert("RGB")
        else:
            return Image.new("RGB", (1200, 800), (255, 255, 255))
    
    def _load_phone_image(self, filename: str) -> Optional[Image.Image]:
        phone_path = self.resources_path / filename
        if phone_path.exists():
            return Image.open(phone_path).convert("RGBA")
        else:
            print(f"Image file not found: {filename}")
            return None
    
    def _resize_image(self, image: Image.Image, size: Tuple[int, int]) -> Image.Image:
        try:
            return image.resize(size, Image.Resampling.LANCZOS)
        except AttributeError:
            return image.resize(size, Image.LANCZOS)
    
    def wrap_text(self, text: str, max_width: int, font: ImageFont.FreeTypeFont) -> List[str]:
        if not text:
            return []
        
        try:
            avg_char_width = font.getbbox("가")[2] if hasattr(font, 'getbbox') else 20
        except:
            avg_char_width = 20
        
        if avg_char_width <= 0:
            avg_char_width = 20
        
        chars_per_line = max(1, int(max_width / avg_char_width))
        
        wrapper = textwrap.TextWrapper(width=chars_per_line, break_long_words=True)
        return wrapper.fill(text).split('\n')
    
    def generate_individual_previews(self, output_dir: str) -> List[str]:
        print("Starting individual App Store preview image generation")
        
        background = self._load_background_image()
        
        generated_files = []
        
        for idx, config in enumerate(self.device_configs, 1):
            print(f"Processing: {config.filename} (index: {idx})")
            
            phone_image = self._load_phone_image(config.filename)
            if phone_image is None:
                continue
            
            work_image = background.convert("RGBA")
            
            bg_width, bg_height = work_image.size
            
            original_width, original_height = phone_image.size
            scale_factor = config.scale_factor
            new_width = int(original_width * scale_factor)
            new_height = int(original_height * scale_factor)
            phone_image = self._resize_image(phone_image, (new_width, new_height))
            
            phone_x = (bg_width - new_width) // 2
            phone_y = bg_height - new_height + config.phone_y_offset
            
            work_image.paste(phone_image, (phone_x, phone_y), phone_image)
            
            text_center_x = phone_x + (new_width // 2)
            
            max_text_width = bg_width - 200
            text_lines = self.wrap_text(config.text, max_text_width, self.font_manager.get_title_font())
            
            line_height = self.font_size_title + 20
            
            total_text_height = len(text_lines) * line_height - 20
            
            text_y = phone_y + config.text_y_offset - (total_text_height // 2)
            
            draw = ImageDraw.Draw(work_image)
            
            for line_idx, line in enumerate(text_lines):
                temp_draw = ImageDraw.Draw(Image.new('RGBA', (1, 1)))
                bbox = temp_draw.textbbox((0, 0), line, font=self.font_manager.get_title_font())
                line_width = bbox[2] - bbox[0]
                line_x = text_center_x - (line_width // 2)
                line_y = text_y + (line_idx * line_height)
                
                draw.text((line_x, line_y), line, font=self.font_manager.get_title_font(), fill=(0, 0, 0))
            
            filename = f"{Path(config.filename).stem}_{self.fastlane_device_identifier}_{idx:02d}.jpg"
            output_path = Path(output_dir) / filename
            saved_path = self._save_image(work_image, str(output_path))
            generated_files.append(saved_path)
        
        return generated_files
    
    def _save_image(self, image: Image.Image, output_path: str) -> str:
        try:
            output_dir = Path(output_path).parent
            output_dir.mkdir(parents=True, exist_ok=True);
            
            if image.mode == 'RGBA':
                rgb_image = Image.new('RGB', image.size, (255, 255, 255))
                rgb_image.paste(image, mask=image.split()[3])
                image = rgb_image
            
            image.save(output_path, format='JPEG', quality=95, dpi=(300, 300))
            print(f"Image saved: {output_path}")
            return output_path
        except Exception as e:
            print(f"Error saving image: {str(e)}")
            raise

def generate_appstore_previews(app_name: str, language: str, device_type: str):
    config_path = Path(__file__).parent / "resources" / "config" / "plots_config.json"
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            config_data = json.load(f)
        output_base_dir = config_data.get("output_base_dir", "output")
    except FileNotFoundError:
        print(f"Error: Config file not found: {config_path}")
        return
    except Exception as e:
        print(f"Error loading config file: {e}")
        return

    generator = AppStorePreviewGenerator(language=language, device_type=device_type)
    
    output_dir = Path(__file__).parent / output_base_dir / app_name / device_type / language
    output_dir.mkdir(parents=True, exist_ok=True)
    
    try:
        generated_files = generator.generate_individual_previews(str(output_dir))
        print(f"App Store preview image generation complete: {len(generated_files)} files")
        for file_path in generated_files:
            print(f"  - {file_path}")
    except Exception as e:
        print(f"Error generating images: {e}")

if __name__ == "__main__":
    # This block is primarily for testing or direct execution with hardcoded values.
    # For production use, run_appstore_preview.py should be used.
    # Example usage:
    # generate_appstore_previews(app_name="plots", language="en-US")
    print("Please use run_appstore_preview.py to generate App Store previews.")