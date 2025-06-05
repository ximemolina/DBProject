import { Router } from 'express';
import * as empleadoController from '../controller/empleadoController.js';

const router = Router();

//ruta para ir a la página principal
router.get('/ventanaPrincipalEmpleado', empleadoController.EmpleadoMainFile);

//ruta para regresar a admin main
router.post('/regresarAdmin', empleadoController.regresarAdmin)

//ruta para ir a ventana de consultar planilla mes
router.get('/ventanaMes', empleadoController.ConsultaMesFile);

//ruta para ir a ventana de consultar planilla semana
router.get('/ventanaSemana', empleadoController.ConsultaSemanaFile);

export default router;