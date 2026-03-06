## Architecture logicielle globale
 Puddle Eyes V2 Module
                │
        Bluetooth / WiFi
                │
        JSON / CSV data (angle, x, y, z)
                │
        ┌─────────────────────────────┐
        │         Middleware          │
        │ (Data parsing, 3D calc)    │
        └─────┬───────────────────────┘
              │
      ┌───────┴────────┐
      │                │
  Mobile App       Radio Tactile
  iOS / Android    Apple CarPlay / Android Auto

## Stack technologique recommandée

# Cible	------------------------------- Technologie	---------------------------------- Avantage
Mobile (iOS / Android)              	Flutter / Dart	                              UI rapide, un seul code base, cross-platform
Radio / CarPlay / AA                	Flutter + platform channels                   Intégration CarPlay / Android Auto avec overlay
Visualisation 3D                    	Flutter + flutter_3d / SceneKit / ARKit       Nuage de points et heatmap dynamique
Communication module                	Bluetooth LE                                  Faible consommation, transmission JSON/CSV

## Commmunication Module -> APP:

Format recommandé : JSON

[
 {"sensor":"left","x":-0.8,"y":3.2,"z":-0.35},
 {"sensor":"center","x":0.0,"y":3.0,"z":-0.40},
 {"sensor":"right","x":0.8,"y":3.1,"z":-0.38}
]

Chaque point = 1 mesure mmWave

x = largeur par rapport au centre du véhicule

y = distance devant le véhicule

z = profondeur réelle (mètre ou cm)