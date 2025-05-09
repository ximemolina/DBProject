import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export const mainFile = async (req, res) => {
    res.sendFile(path.join(__dirname, '../views/login.html'));
};