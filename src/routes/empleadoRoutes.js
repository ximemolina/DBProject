import { Router } from 'express';
import * as empleadoController from '../controller/empleadoController.js';

const router = Router();

//ruta para ir a la página principal
router.get('/ventanaPrincipalEmpleado', empleadoController.EmpleadoMainFile);

export default router;