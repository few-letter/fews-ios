"""
Font management module for App Store preview generation
"""

from PIL import ImageFont
from pathlib import Path
import platform
import json
from typing import Optional, Dict, Any, Tuple


class FontManager:
    """Manages font loading and configuration for different languages"""
    
    def __init__(self, fonts_path: Path, language: str = "ko", font_size_title: int = 100, font_size_body: int = 32):
        self.fonts_path = fonts_path
        self.language = language
        self.font_size_title = font_size_title
        self.font_size_body = font_size_body
        self.default_font = ImageFont.load_default()
        
        # Load language-specific font configuration
        self.font_mapping = self._load_language_font_config()
        
        # Initialize fonts
        self.title_font = None
        self.body_font = None
        
    def _load_language_font_config(self) -> Dict[str, Any]:
        """Load language-specific font configuration from config file"""
        config_path = self.fonts_path.parent / "config" / "plots_config.json"
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                config_data = json.load(f)
            
            localized_data = config_data.get('localization', {})
            language_config = localized_data.get(self.language, {})
            
            if not language_config:
                print(f"Warning: No font configuration found for language '{self.language}'. Using 'ko' as fallback.")
                language_config = localized_data.get("ko", {})
            
            font_mapping = language_config.get('font_mapping', {})
            
            # Set default font mapping if not found
            if not font_mapping:
                font_mapping = {
                    "regular": "NotoSans-Regular.ttf",
                    "bold": "NotoSans-Bold.ttf",
                    "font_path": "NotoSans"
                }
            
            print(f"Font mapping loaded for language '{self.language}': {font_mapping}")
            return font_mapping
            
        except FileNotFoundError:
            print(f"Error: Config file not found: {config_path}")
            return self._get_default_font_mapping()
        except Exception as e:
            print(f"Error loading font configuration: {e}")
            return self._get_default_font_mapping()
    
    def _get_default_font_mapping(self) -> Dict[str, Any]:
        """Get default font mapping"""
        return {
            "regular": "NotoSans-Regular.ttf",
            "bold": "NotoSans-Bold.ttf",
            "font_path": "NotoSans"
        }
    
    def load_fonts(self) -> bool:
        """Load fonts based on configuration with fallback chain"""
        try:
            # Try custom fonts first
            if self._load_custom_fonts():
                return True
            
            # Try fallback font if specified
            elif self._load_fallback_font():
                return True
            
            # Try system fonts
            elif self._load_system_fonts():
                return True
            
            # Final fallback to default fonts
            else:
                print("Loading default fonts")
                self._load_default_fonts()
                return True
                
        except Exception as e:
            print(f"Font loading failed: {e}")
            self._load_default_fonts()
            return False
    
    def _load_custom_fonts(self) -> bool:
        """Load custom fonts based on language configuration"""
        try:
            # Check if system font should be used
            if self.font_mapping.get("use_system_font", False):
                print(f"Using system font for language '{self.language}'")
                return False  # This will trigger system font loading
            
            # Check if variable font should be used
            if self.font_mapping.get("variable_font"):
                return self._load_variable_font()
            
            # Use language-specific font mapping (static fonts)
            return self._load_static_fonts()
            
        except Exception as e:
            print(f"Error loading custom fonts for language '{self.language}': {e}")
            return False
    
    def _load_variable_font(self) -> bool:
        """Load variable font with weight variations"""
        variable_font_name = self.font_mapping.get("variable_font")
        font_path = self.font_mapping.get("font_path", "")
        
        if font_path:
            variable_font_path = self.fonts_path / font_path / variable_font_name
        else:
            variable_font_path = self.fonts_path / variable_font_name
        
        if not variable_font_path.exists():
            print(f"Variable font not found: {variable_font_path}")
            return False
        
        print(f"Loading variable font for language '{self.language}': {variable_font_path}")
        
        try:
            # Try with highest weight values for maximum bold effect
            weight_values = [1000, 950, 900, 800, 700]  # Try from highest to lowest
            
            for weight in weight_values:
                try:
                    print(f"Trying weight {weight} for title font...")
                    title_font = ImageFont.truetype(
                        str(variable_font_path), 
                        self.font_size_title,
                        font_variant={'wght': weight}
                    )
                    body_font = ImageFont.truetype(
                        str(variable_font_path), 
                        self.font_size_body,
                        font_variant={'wght': 500}  # Medium weight for body
                    )
                    
                    self.title_font = title_font
                    self.body_font = body_font
                    print(f"Successfully loaded variable font with weight {weight}: {variable_font_path}")
                    return True
                
                except Exception as e:
                    print(f"Weight {weight} failed: {e}")
                    continue
            
            # If all weights failed, try default approach
            print("All weight values failed, trying default approach...")
            raise Exception("All weight values failed")
            
        except Exception as e:
            print(f"Error loading variable font with font_variant: {e}")
            
            # Fallback: Try loading without font_variant
            try:
                print("Trying to load variable font without font_variant...")
                self.title_font = ImageFont.truetype(str(variable_font_path), self.font_size_title)
                self.body_font = ImageFont.truetype(str(variable_font_path), self.font_size_body)
                print(f"Successfully loaded variable font without variant: {variable_font_path}")
                return True
            except Exception as e2:
                print(f"Error loading variable font without variant: {e2}")
                
                # Try system font fallback if enabled
                if self.font_mapping.get("use_system_font_fallback", False):
                    print("Trying system font fallback for CJK language...")
                    return self._try_system_font_fallback()
                
                return False
    
    def _load_static_fonts(self) -> bool:
        """Load static fonts (regular and bold)"""
        font_path = self.font_mapping.get("font_path", "NotoSans")
        regular_font_name = self.font_mapping.get("regular", "NotoSans-Regular.ttf")
        bold_font_name = self.font_mapping.get("bold", "NotoSans-Bold.ttf")
        
        # Try to find the font files in the font directory structure
        regular_font_path, bold_font_path = self._find_font_files(font_path, regular_font_name, bold_font_name)
        
        # Check if both font files exist
        if not (regular_font_path and regular_font_path.exists() and 
                bold_font_path and bold_font_path.exists()):
            print(f"Font files not found for language '{self.language}':")
            if regular_font_path:
                print(f"  Regular font: {regular_font_path} (exists: {regular_font_path.exists()})")
            if bold_font_path:
                print(f"  Bold font: {bold_font_path} (exists: {bold_font_path.exists()})")
            return False
        
        # Load the fonts
        self.title_font = ImageFont.truetype(str(bold_font_path), self.font_size_title)
        self.body_font = ImageFont.truetype(str(regular_font_path), self.font_size_body)
        
        print(f"Successfully loaded fonts for language '{self.language}':")
        print(f"  Regular font: {regular_font_path}")
        print(f"  Bold font: {bold_font_path}")
        
        return True
    
    def _find_font_files(self, font_path: str, regular_font_name: str, bold_font_name: str) -> Tuple[Optional[Path], Optional[Path]]:
        """Find font files in various possible locations"""
        # First, try the direct font path (for our CJK OTF fonts)
        direct_regular_path = self.fonts_path / font_path / regular_font_name
        direct_bold_path = self.fonts_path / font_path / bold_font_name
        
        if direct_regular_path.exists() and direct_bold_path.exists():
            return direct_regular_path, direct_bold_path
        
        # Fallback: try the unhinted/ttf directory structure
        font_base_path = self.fonts_path / font_path / "unhinted" / "ttf"
        regular_font_path = font_base_path / regular_font_name
        bold_font_path = font_base_path / bold_font_name
        
        # If not found, try the direct font name in fonts root
        if not regular_font_path.exists():
            regular_font_path = self.fonts_path / regular_font_name
        if not bold_font_path.exists():
            bold_font_path = self.fonts_path / bold_font_name
        
        # If still not found, try alternative locations
        if not regular_font_path.exists():
            for alt_path in ["hinted/ttf", "googlefonts/ttf", "full/ttf"]:
                alt_font_path = self.fonts_path / font_path / alt_path / regular_font_name
                if alt_font_path.exists():
                    regular_font_path = alt_font_path
                    break
        
        if not bold_font_path.exists():
            for alt_path in ["hinted/ttf", "googlefonts/ttf", "full/ttf"]:
                alt_font_path = self.fonts_path / font_path / alt_path / bold_font_name
                if alt_font_path.exists():
                    bold_font_path = alt_font_path
                    break
        
        return regular_font_path, bold_font_path
    
    def _load_system_fonts(self) -> bool:
        """Load system fonts with CJK language support"""
        system = platform.system()
        try:
            if system == 'Darwin':
                # For CJK languages, try CJK-supporting fonts first
                if self.language in ['ko', 'ja', 'zh-Hans', 'zh-Hant']:
                    if self._load_cjk_system_fonts():
                        return True
                
                # For non-CJK languages or fallback
                return self._load_general_system_fonts()
            else:
                # For non-macOS systems, try common fonts
                return self._load_common_fonts()
        except Exception as e:
            print(f"Error loading system fonts: {e}")
            return False
    
    def _load_cjk_system_fonts(self) -> bool:
        """Load CJK-specific system fonts on macOS"""
        cjk_font_paths = [
            # Korean fonts
            '/System/Library/Fonts/AppleSDGothicNeo.ttc',
            '/System/Library/Fonts/Supplemental/AppleSDGothicNeo.ttc',
            '/Library/Fonts/AppleSDGothicNeo.ttc',
            # Chinese fonts
            '/System/Library/Fonts/PingFang.ttc',
            '/System/Library/Fonts/Supplemental/PingFang.ttc',
            '/System/Library/Fonts/PingFangSC-Regular.otf',
            '/System/Library/Fonts/PingFangTC-Regular.otf',
            # Japanese fonts
            '/System/Library/Fonts/Hiragino Sans GB.ttc',
            '/System/Library/Fonts/HiraginoSans-W3.otf',
            '/System/Library/Fonts/HiraginoSans-W6.otf',
            # Fallback
            '/System/Library/Fonts/STHeiti Light.ttc',
            '/System/Library/Fonts/STHeiti Medium.ttc',
        ]
        
        for font_path in cjk_font_paths:
            if Path(font_path).exists():
                print(f"Loading CJK system font: {font_path}")
                self.title_font = ImageFont.truetype(font_path, self.font_size_title)
                self.body_font = ImageFont.truetype(font_path, self.font_size_body)
                return True
        
        return False
    
    def _load_general_system_fonts(self) -> bool:
        """Load general system fonts on macOS"""
        base_paths = [
            '/System/Library/Fonts/AppleSDGothicNeo.ttc',
            '/System/Library/Fonts/Supplemental/AppleSDGothicNeo.ttc',
            '/Library/Fonts/AppleSDGothicNeo.ttc',
            '/System/Library/Fonts/Helvetica.ttc',
            '/System/Library/Fonts/Arial.ttf'
        ]
        
        for path in base_paths:
            if Path(path).exists():
                print(f"Loading system font: {path}")
                self.title_font = ImageFont.truetype(path, self.font_size_title)
                self.body_font = ImageFont.truetype(path, self.font_size_body)
                return True
        
        return False
    
    def _load_common_fonts(self) -> bool:
        """Load common fonts on non-macOS systems"""
        common_fonts = [
            'NotoSansCJK-Regular.ttf',
            'NotoSansCJK-Bold.ttf',
            'DejaVuSans.ttf',
            'Arial.ttf'
        ]
        
        for font_name in common_fonts:
            try:
                self.title_font = ImageFont.truetype(font_name, self.font_size_title)
                self.body_font = ImageFont.truetype(font_name, self.font_size_body)
                print(f"Loading system font: {font_name}")
                return True
            except:
                continue
        
        return False
    
    def _try_system_font_fallback(self) -> bool:
        """Try system font fallback for CJK languages"""
        return self._load_system_fonts()
    
    def _load_fallback_font(self) -> bool:
        """Load fallback font if specified in configuration"""
        fallback_font_path_name = self.font_mapping.get("fallback_font_path")
        if not fallback_font_path_name:
            return False
        
        try:
            fallback_font_path = self.fonts_path / fallback_font_path_name
            if fallback_font_path.exists():
                self.title_font = ImageFont.truetype(str(fallback_font_path), self.font_size_title)
                self.body_font = ImageFont.truetype(str(fallback_font_path), self.font_size_body)
                print(f"Fallback font loaded successfully: {fallback_font_path_name}")
                return True
            else:
                print(f"Fallback font file not found: {fallback_font_path}")
                return False
        except Exception as e:
            print(f"Error loading fallback font: {e}")
            return False
    
    def _load_default_fonts(self):
        """Load default fonts as final fallback"""
        self.title_font = ImageFont.load_default()
        self.body_font = ImageFont.load_default()
    
    def get_title_font(self) -> ImageFont.FreeTypeFont:
        """Get the title font"""
        return self.title_font or self.default_font
    
    def get_body_font(self) -> ImageFont.FreeTypeFont:
        """Get the body font"""
        return self.body_font or self.default_font 