import { Router } from 'express';
import generalRoutes from './generalRoutes.js';
import principalAdminRoutes from './principalAdminRoutes.js';
import loginRoutes from './loginRoutes.js';
import modificarEmpleado from './modificarEmpleadoRoutes.js';

const rutas_init = () => {
  const router = Router()

  router.use('/', generalRoutes);
  router.use('/principalAdmin', principalAdminRoutes);
  router.use('/modificarEmpleado', modificarEmpleado);
  router.use('/login', loginRoutes);
  router.use('/general', generalRoutes);

  return router
}

export default rutas_init;