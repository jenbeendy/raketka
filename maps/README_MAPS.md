### Map Creation Guide

To create a new map for Raketka:

1. Open your favorite bitmap editor (Paint, Photoshop, GIMP, Aseprite).
2. Create an image (recommended size: 64x64 or 128x128).
3. Draw pixels to represent game objects:
   - **Black (#000000)**: Wall / Obstacle
   - **Green (#00FF00)**: Start Position (Player Spawn)
   - **Red (#FF0000)**: End Position (Goal)
   - **Blue (#0000FF)**: Fuel Station
   - **Yellow (#FFFF00)**: Bonus (Fuel/Speed)
   - **White/Transparent**: Empty Space

4. Save the image as `.png` in `raketka/maps/`.
5. Update the game configuration or loader to point to your new map.
