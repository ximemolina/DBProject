import { Router } from 'express';
import * as loginController from '../controller/loginController.js';

const router = Router();

//consigue la el Ip del usuario
router.get('/getIp', loginController.getIp);

//valida datos del login
router.post('/revLogin',loginController.revisarLogin);

//revisar si usuario es admin o cliente
router.post('/revTipoUsuario',loginController.revisarTipoUsuario);

export default router;