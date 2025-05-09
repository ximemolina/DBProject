import express from 'express';
import rutas_init from "../routes/indexRoutes.js";

const configApi = (app) =>{
    app.use(express.json())
    app.use(express.urlencoded({extended: true}))
    app.use(express.static('public'))
}

const configuracionRouter = (app) =>{
    app.use('/', rutas_init())
}

const init = () => {
    const app = express()
    configApi(app)
    configuracionRouter(app)
    app.listen(3300)
    console.log("Iniciado servidor")
}

//Inicializar servidor
init(); 