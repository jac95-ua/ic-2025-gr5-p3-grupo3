# IC_P3
Diagrama de dependencias:
          [ Cargar Imagen (image) ]
                        |
   +--------------------+--------------------+--------------------+--------------------+
   |                    |                    |                    |                    |
   v                    v                    v                    v                    v
[ compute_srm(3) ] [ compute_srm(5) ] [ compute_ela ] [ compute_dct(true) ] [ compute_dct(false) ]
   |                    |                    |                    |                    |
   v                    v                    v                    v                    v
[ Guardar SRM 3x3 ] [ Guardar SRM 5x5 ] [ Guardar ELA ] [ Guardar DCT Inv ] [ Guardar DCT Dir ]
