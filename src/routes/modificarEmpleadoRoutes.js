import { Router } from 'express';
import * as modificarController from '../controller/modificarEmpleadoController.js';

const router = Router();

//ruta para ir a la página modificar
router.get('/ventanaModificar', modificarController.modificarFile);

//ruta para obtener infromacion del empleado 
router.post('/datosEmpleado', modificarController.datosEmpleado);

//ruta para generar el menu dropdown puesto
router.get('/generarMenuPuesto', modificarController.generarMenuPuesto);

//ruta para generar el menu dropdown tipo doc id
router.get('/generarMenuTipoDocId', modificarController.generarMenuTipoDocId);

//ruta para generar el menu dropdown departamento
router.get('/generarMenuDepartamento', modificarController.generarMenuDepartamento);

//ruta para modificar empleado
router.post('/modificarEmpleado', modificarController.modificarEmpleado);

export default router;