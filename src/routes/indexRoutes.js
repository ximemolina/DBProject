import { Router } from 'express';
import generalRoutes from './generalRoutes.js';
import principalAdminRoutes from './principalAdminRoutes.js';

const rutas_init = () => {
  const router = Router()

  router.use('/', generalRoutes);
  router.use('/principalAdmin', principalAdminRoutes);

  return router
}

export default rutas_init;