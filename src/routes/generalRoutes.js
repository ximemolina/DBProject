import { Router } from 'express';
import * as generalController from '../controller/generalController.js';

const router = Router();

//ruta principal apenas se inicializa el server
router.get('/', generalController.mainFile);

//ruta para obtener descripcion de errores
router.post('/getError', generalController.getError);

//ruta para actualizar evento logout
router.post('/logout', generalController.logout);

export default router;