import { Router } from 'express';
import generalRoutes from './generalRoutes.js';
import principalAdminRoutes from './principalAdminRoutes.js';
import empleadoRoutes from './empleadoRoutes.js';
import loginRoutes from './loginRoutes.js';
import modificarEmpleado from './modificarEmpleadoRoutes.js';
import eliminarEmpleadoRoutes from './eliminarEmpleadoRoutes.js';
import insertarEmpleadoRoutes from './insertarEmpleadoRoutes.js';

const rutas_init = () => {
  const router = Router()

  router.use('/', generalRoutes);
  router.use('/principalAdmin', principalAdminRoutes);
  router.use('/modificarEmpleado', modificarEmpleado);
  router.use('/login', loginRoutes);
  router.use('/general', generalRoutes);
  router.use('/empleado', empleadoRoutes);
  router.use('/eliminarEmpleado', eliminarEmpleadoRoutes);
  router.use('/insertarEmpleado', insertarEmpleadoRoutes);

  return router
}

export default rutas_init;