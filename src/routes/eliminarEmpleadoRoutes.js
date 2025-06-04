import { Router } from 'express';
import * as eliminarEmpleadoController from '../controller/eliminarEmpleadoController.js';

const router = Router();

//ruta para eliminar el empleado
router.post('/eliminarEmpleado', eliminarEmpleadoController.eliminarEmpleado)

export default router;