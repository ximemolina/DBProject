import { Router } from 'express';
import * as generalController from '../controller/generalController.js';

const router = Router();

//ruta principal apenas se inicializa el server
router.get('/', generalController.mainFile);

export default router;