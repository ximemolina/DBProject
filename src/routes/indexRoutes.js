import { Router } from 'express';
import generalRoutes from './generalRoutes.js';
import principalAdminRoutes from './principalAdminRoutes.js';
import empleadoRoutes from './empleadoRoutes.js';
import loginRoutes from './loginRoutes.js';

const rutas_init = () => {
  const router = Router()

  router.use('/', generalRoutes);
  router.use('/principalAdmin', principalAdminRoutes);
  router.use('/login', loginRoutes);
  router.use('/general', generalRoutes);
  router.use('/empleado', empleadoRoutes);

  return router
}

export default rutas_init;