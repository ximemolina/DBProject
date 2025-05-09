import { Router } from 'express';
import generalRoutes from './generalRoutes.js';

const rutas_init = () => {
  const router = Router()

  router.use('/', generalRoutes);

  return router
}

export default rutas_init;