import { Router } from 'express';
import * as generalController from '../controller/generalController.js';

const router = Router();

//ruta principal apenas se inicializa el server
router.get('/', generalController.mainFile);

//ruta para obtener descripcion de errores
router.post('/getError', generalController.getError);

export default router;