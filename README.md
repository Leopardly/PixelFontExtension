# PixelFont

PixelFont is a "font replacement" for the Ironmon-Tracker that replaces the default font rendering behaviour with characters that are predefined. This is designed mostly to help Linux users who may be experiencing some of the following issues: 
- missing default fonts or text size issues with fallback fonts
- anti-aliasing or blurry text
- terrible font rendering even with the correct fonts installed

Best efforts have been made to ensure spacing and alignment have been maintained throughout; please let me know if you find any places with alignment or other issues.

## Examples

### Before

<img width="650" height="333" alt="An image showing terrible looking font" src="https://github.com/user-attachments/assets/e503e4b8-fa92-4ad1-9f82-ef3176f16b9d" />
<img width="650" height="333" alt="An image with some blurry text" src="https://github.com/user-attachments/assets/5b820ca8-4938-4bb0-be75-bcab304e71b1" />

### After

<img width="650" height="333" alt="An image showing a nice neat font" src="https://github.com/user-attachments/assets/b45d1243-0707-4778-8ed1-69c0664677ff" />



## Caveats
- This extension does not currently support languages other than English, further logic changes would likely be warranted to ensure taller characters like Á and Ã are handled better. This may come later.
- There is no "Header" font used in this extension, previous Headers, for example the Pokemon Name on the Pokemon Details screen, will instead, simply be rendered at the same size as other text.
