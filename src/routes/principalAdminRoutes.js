import { Router } from 'express';
import * as principalAdminController from '../controller/principalAdminController.js';

const router = Router();

//ruta para ir a la página principal
router.get('/ventanaPrincipalAdmin', principalAdminController.principalAdminFile);

//ruta para listar todos los empleados activos
router.get('/listarEmpleados', principalAdminController.listarEmpleados);

//ruta para listar todos los empleados activos por nombre
router.post('/listarEmpleadosNombre', principalAdminController.listarEmpleadosNombre);



export default router;