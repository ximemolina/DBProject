import { Router } from 'express';
import * as insertarController from '../controller/insertarEmpleadoController.js';

const router = Router();

//ruta para ir a la página insertar
router.get('/ventanaInsertar', insertarController.insertarFile);

//ruta para insertar nuevo empleado
router.post('/insertarEmpleado', insertarController.insertarEmpleado);

export default router;