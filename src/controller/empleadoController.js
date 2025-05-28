import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export const EmpleadoMainFile = async (req, res) => {
    res.sendFile(path.join(__dirname, '../views/principalEmpleado.html')); //sirve el html de la página inicial
};