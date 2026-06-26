# casino-frontend

Frontend del casino VidalCasino 2.0. SPA en Angular 17 servida por nginx. Se comunica con los microservicios del clúster mediante el DNS interno de Kubernetes y se expone públicamente a través de un Service tipo LoadBalancer en Amazon EKS.

## Stack

- Angular 17
- nginx (puerto interno 8080)
- Docker + Amazon ECR
- Kubernetes (Amazon EKS)

## Puerto

| Entorno | Puerto |
|---------|--------|
| Local | 80 |
| Clúster | LoadBalancer :80 → nginx :8080 |

## Rutas nginx

| Prefijo | Destino |
|---------|---------|
| `/api/bonos` | `http://bonos-service:8004` |
| `/api/apuestas` | `http://apuestas-service:8005` |
| `/api/estadisticas` | `http://estadisticas-service:8006` |
| `/api/` | `http://backend:3000` |
| `/` | Angular SPA |

## Construcción local

```bash
docker build -t casino-frontend .
docker run -p 80:8080 casino-frontend
```

## Despliegue en EKS

El pipeline CI/CD se dispara automáticamente con push a la rama `deploy`:

```bash
git checkout deploy
git merge dev
git push origin deploy
```

El pipeline hace:
1. Build de producción Angular + imagen Docker
2. Push a Amazon ECR con tags `latest`, `v1.0.0` y `$GITHUB_SHA`
3. Deploy en EKS con `kubectl apply`

## URL pública

El Service tipo LoadBalancer crea automáticamente un ELB en AWS al aplicar el manifiesto. La URL pública se obtiene con:

```bash
kubectl get service casino-frontend
```

## Comandos útiles

```bash
# Ver pods
kubectl get pods | grep frontend

# Ver logs nginx
kubectl logs deployment/casino-frontend

# Ver HPA
kubectl get hpa casino-frontend-hpa

# Ver URL pública
kubectl get service casino-frontend
```

## Troubleshooting

| Problema | Solución |
|----------|----------|
| CrashLoopBackOff | `kubectl logs deployment/casino-frontend` |
| 502 Bad Gateway | Verificar que los pods de backend estén Running |
| 404 en /api/ | Revisar configuración nginx y nombres de Services en K8s |
| Pipeline falla | Actualizar GitHub Secrets con nuevas credenciales del Learner Lab |

## Ramas

| Rama | Uso |
|------|-----|
| `main` | Referencia estable |
| `dev` | Desarrollo diario |
| `deploy` | Dispara el pipeline CI/CD |