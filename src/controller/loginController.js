import * as functionsDB from '../model/loginDB.js'

export const getIp = async (req, res) => {
    let ip =
        req.headers['x-forwarded-proto'] ||
        req.headers['cf-connecting-ip'] ||
        req.headers['x-real-ip'] ||
        req.headers['x-forwarded-for'] ||
        req.socket.remoteAddress ||
        '';

    if (ip == '::1') { //por ser server local siempre mandará ::1, el cual es equivalente a '127.0.0.1'
        ip = '127.0.0.1';
    }

    res.send(ip);
};

export const revisarLogin = async (req,res) => {
    const { username, password, ipAdress } = req.body;
    const resultado = await functionsDB.revisarLogin(username,password,ipAdress);
    res.json({resultado});
};

export const revisarTipoUsuario = async (req,res) => {
    const {username} = req.body;
    const resultado = await functionsDB.revisarTipoUsuario(username);
    res.json({resultado});
}