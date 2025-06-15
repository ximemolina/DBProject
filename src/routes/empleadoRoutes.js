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

//ruta para ir a ventana de consultar planilla semana
router.get('/ventanaMovimientos', empleadoController.ConsultaMovimientoFile);

//desplegar informacion de planilla mensual
router.post('/listarPlanillaMes', empleadoController.listarPlanillaMes);

//desplegar informacion de movimientos
router.post('/listarMovimientos', empleadoController.listarMovimientos);

//desplegar desglose de deducciones mensuales
router.post('/desplegarDeducciones', empleadoController.desplegarDeducciones);

//desplegar informacion de planilla semanal
router.post('/listarPlanillaSemana', empleadoController.listarPlanillaSemana);

//desplegar desglose de deducciones semanales
router.post('/desplegarDeduccionesSemana', empleadoController.desplegarDeduccionesSemana);

//desplegar informacion sobre salarios
router.post('/desplegarSalario', empleadoController.desplegarSalario);

//desplegar informacion sobre salarios
router.post('/desgloseMovimientos', empleadoController.desplegarMovs);

export default router;