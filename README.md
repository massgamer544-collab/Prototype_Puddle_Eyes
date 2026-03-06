# Prototype_Puddle_Eyes
 
 Prototype system to detect and visualize mod or water holes in front of an offroad vehicule.

# Goal:
 Provide a 3D depth estimation vefore entering a puddle os mud pit.

# Code idea:
 Scan the terrain  using ultrasonic sensors and reconstruct a 3D view.

 # Hardware:
 - ESP32
 - Waterproof ultrasonic sensor
 - Servo Scanning system

 # Features (planned)
 - Terrain scanning 
 - 3D depth visualization
 - Safe path estimation
 - Mobile display

 
# Flux du produit 
Scan du terrain 
↓
Analyse profondeur
↓
Classification risque
↓
Affichage téléphone

# Résultat dans l'app mobile :
SAFE      🟢  < 20 cm
CAUTION   🟡  20-40 cm
DANGER    🔴  > 40 cm