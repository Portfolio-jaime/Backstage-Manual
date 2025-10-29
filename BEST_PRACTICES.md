# 🏆 Mejores Prácticas Globales - Backstage Solutions

[![Best Practices](https://img.shields.io/badge/Best_Practices-Guide-4CAF50?style=for-the-badge&logo=checklist&logoColor=white)](#)
[![DevOps](https://img.shields.io/badge/DevOps-Practices-FF6B6B?style=for-the-badge&logo=devdotto&logoColor=white)](#)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Best--Practices-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)

> **Guía comprehensiva de mejores prácticas** para desarrollo, despliegue y operación de la plataforma Backstage Solutions. Desde desarrollo hasta producción.

## 📋 Tabla de Contenidos

### 🏗️ **Por Área**
- [**💻 Desarrollo**](#development) - Prácticas de código y desarrollo
- [**☸️ Kubernetes**](#kubernetes) - Despliegue y orquestación
- [**🔒 Seguridad**](#security) - Protección y compliance
- [**📊 Monitoreo**](#monitoring) - Observabilidad y alertas
- [**🚀 DevOps**](#devops) - CI/CD y automatización
- [**🐘 Base de Datos**](#database) - PostgreSQL y persistencia

### 🎯 **Por Nivel**
- [**🟢 Esenciales**](#essential) - Prácticas críticas
- [**🟡 Recomendadas**](#recommended) - Mejoras importantes
- [**🔴 Avanzadas**](#advanced) - Optimizaciones expertas

---

## 💻 Desarrollo - Code & Development Practices

### 🟢 **Esenciales**

#### 📝 **Control de Versiones**
```bash
# ✅ Hacer commits pequeños y frecuentes
git add -p  # Stage hunks interactivamente
git commit -m "feat: add user authentication

- Add JWT token validation
- Implement login endpoint
- Add user session management"

# ✅ Usar conventional commits
# feat: nueva funcionalidad
# fix: corrección de bug
# docs: cambios en documentación
# refactor: refactorización de código
```

#### 🧪 **Testing Strategy**
```typescript
// ✅ Tests unitarios para lógica crítica
describe('UserService', () => {
  it('should authenticate valid user', async () => {
    const result = await userService.authenticate(credentials);
    expect(result.token).toBeDefined();
  });
});

// ✅ Tests de integración para APIs
describe('Catalog API', () => {
    it('should return entities with pagination', async () => {
      const response = await request(app)
        .get('/api/catalog/entities?page=1&size=10')
        .expect(200);

      expect(response.body.items).toHaveLength(10);
    });
});
```

#### 📚 **Documentación**
```typescript
// ✅ Documentar APIs con JSDoc
/**
 * Authenticates a user with email and password
 * @param {Object} credentials - User credentials
 * @param {string} credentials.email - User email
 * @param {string} credentials.password - User password
 * @returns {Promise<Object>} Authentication result with token
 * @throws {AuthenticationError} When credentials are invalid
 */
async function authenticateUser(credentials: UserCredentials): Promise<AuthResult> {
  // Implementation
}
```

### 🟡 **Recomendadas**

#### 🏛️ **Arquitectura Limpia**
```typescript
// ✅ Separar responsabilidades
// src/
├── domain/          # Reglas de negocio
├── application/     # Casos de uso
├── infrastructure/  # Adaptadores externos
├── presentation/    # Controllers, routes
└── shared/         # Utilidades compartidas
```

#### 🔄 **Gestión de Estado**
```typescript
// ✅ Usar inmutabilidad
const userReducer = (state = initialState, action) => {
  switch (action.type) {
    case 'USER_LOGIN_SUCCESS':
      return {
        ...state,
        user: action.payload,
        isAuthenticated: true,
        loading: false
      };
    default:
      return state;
  }
};
```

### 🔴 **Avanzadas**

#### 📊 **Performance Optimization**
```typescript
// ✅ Lazy loading para bundles grandes
const CatalogPage = lazy(() => import('./pages/CatalogPage'));

// ✅ Memoización para cálculos costosos
const expensiveCalculation = useMemo(() => {
  return computeExpensiveValue(dependencies);
}, [dependencies]);

// ✅ Virtual scrolling para listas grandes
<VirtualizedList
  items={catalogEntities}
  itemHeight={50}
  containerHeight={400}
/>
```

---

## ☸️ Kubernetes - Deployment & Orchestration

### 🟢 **Esenciales**

#### 📋 **Resource Management**
```yaml
# ✅ Definir requests y limits apropiados
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backstage
spec:
  template:
    spec:
      containers:
      - name: backstage
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        # ✅ Health checks
        livenessProbe:
          httpGet:
            path: /healthcheck
            port: 7007
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /healthcheck
            port: 7007
          initialDelaySeconds: 5
          periodSeconds: 5
```

#### 🔐 **Secrets Management**
```yaml
# ✅ Nunca hardcode credentials
apiVersion: v1
kind: Secret
metadata:
  name: backstage-secrets
type: Opaque
data:
  # Base64 encoded
  POSTGRES_PASSWORD: <base64-encoded>
  BACKEND_AUTH_SECRET: <base64-encoded>

---
# ✅ Usar external secret operator para producción
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: backstage-external-secrets
spec:
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: backstage-secrets
  data:
  - secretKey: password
    remoteRef:
      key: database/backstage
      property: password
```

### 🟡 **Recomendadas**

#### 🏷️ **Labels y Selectors**
```yaml
# ✅ Labels consistentes y informativos
metadata:
  labels:
    app: backstage
    component: frontend
    version: v1.2.3
    environment: production
    team: platform
    managed-by: argocd

# ✅ Selectors específicos
spec:
  selector:
    matchLabels:
      app: backstage
      component: frontend
```

#### 🌐 **Network Policies**
```yaml
# ✅ Restringir tráfico entre namespaces
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backstage-network-policy
  namespace: backstage-manual
spec:
  podSelector:
    matchLabels:
      app: backstage
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 7007
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
```

### 🔴 **Avanzadas**

#### 🚀 **Auto-scaling**
```yaml
# ✅ Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backstage-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backstage
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80

# ✅ Vertical Pod Autoscaler (recomendado)
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: backstage-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backstage
  updatePolicy:
    updateMode: "Auto"
```

#### 🔄 **Rolling Updates**
```yaml
# ✅ Estrategia de actualización controlada
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 25%
      maxSurge: 25%
  progressDeadlineSeconds: 600
  minReadySeconds: 30
  revisionHistoryLimit: 10
```

---

## 🔒 Seguridad - Protection & Compliance

### 🟢 **Esenciales**

#### 🛡️ **Principle of Least Privilege**
```yaml
# ✅ ServiceAccount con mínimos permisos
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backstage-sa
  namespace: backstage-manual

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: backstage-role
  namespace: backstage-manual
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: backstage-rolebinding
  namespace: backstage-manual
subjects:
- kind: ServiceAccount
  name: backstage-sa
roleRef:
  kind: Role
  name: backstage-role
  apiGroup: rbac.authorization.k8s.io
```

#### 🔐 **Image Security**
```dockerfile
# ✅ Usar imágenes base oficiales y actualizadas
FROM node:20-alpine

# ✅ Usuario no-root
RUN addgroup -g 1001 -S nodejs
RUN adduser -S backstage -u 1001

# ✅ Instalar solo dependencias de producción
COPY package*.json ./
RUN npm ci --only=production

# ✅ Copiar aplicación
COPY --chown=backstage:nodejs . .

# ✅ Cambiar a usuario no-root
USER backstage

EXPOSE 7007
CMD ["npm", "start"]
```

### 🟡 **Recomendadas**

#### 🔍 **Security Scanning**
```yaml
# ✅ Escaneo automático en CI/CD
- name: Security scan
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'image'
    scan-ref: 'docker.io/jaimehenao8126/backstage-custom:latest'
    format: 'sarif'
    output: 'trivy-results.sarif'

- name: Upload Trivy scan results
  uses: github/codeql-action/upload-sarif@v2
  if: always()
  with:
    sarif_file: 'trivy-results.sarif'
```

#### 📊 **Audit Logging**
```typescript
// ✅ Logging estructurado de seguridad
const securityLogger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({
      filename: 'security.log'
    })
  ]
});

// Uso en autenticación
securityLogger.info('User login attempt', {
  userId: user.id,
  ip: request.ip,
  userAgent: request.get('User-Agent'),
  success: true
});
```

### 🔴 **Avanzadas**

#### 🔐 **Zero Trust Architecture**
```typescript
// ✅ Validación de todas las requests
const authMiddleware = (req: Request, res: Response, next: Function) => {
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!);
    req.user = decoded;
    next();
  } catch (error) {
    securityLogger.warn('Invalid token attempt', {
      ip: req.ip,
      token: token.substring(0, 10) + '...'
    });
    return res.status(401).json({ error: 'Invalid token' });
  }
};
```

#### 🛡️ **Runtime Security**
```yaml
# ✅ Pod Security Standards
apiVersion: pod-security.kubernetes.io/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: MustRunAs
    ranges:
    - min: 1
      max: 65535
  fsGroup:
    rule: MustRunAs
    ranges:
    - min: 1
      max: 65535
```

---

## 📊 Monitoreo - Observability & Alerting

### 🟢 **Esenciales**

#### 📈 **Métricas Clave**
```typescript
// ✅ Métricas de aplicación
const prometheusMetrics = {
  httpRequestsTotal: new prom.Counter({
    name: 'http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'route', 'status_code']
  }),

  httpRequestDuration: new prom.Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['method', 'route']
  }),

  activeConnections: new prom.Gauge({
    name: 'active_connections',
    help: 'Number of active connections'
  })
};

// Uso en middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    prometheusMetrics.httpRequestsTotal
      .labels(req.method, req.route?.path || req.path, res.statusCode.toString())
      .inc();
    prometheusMetrics.httpRequestDuration
      .labels(req.method, req.route?.path || req.path)
      .observe(duration);
  });
  next();
});
```

#### 🚨 **Alertas Críticas**
```yaml
# ✅ Alertas esenciales
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: backstage-critical-alerts
spec:
  groups:
  - name: backstage
    rules:
    - alert: BackstageDown
      expr: up{job="backstage"} == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Backstage is completely down"
        description: "Backstage has been down for more than 5 minutes."

    - alert: HighErrorRate
      expr: rate(http_requests_total{status_code=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High error rate detected"
        description: "Error rate is {{ $value | printf \"%.2f\" }}% over the last 5 minutes."
```

### 🟡 **Recomendadas**

#### 📊 **Dashboards Efectivos**
```json
// ✅ Dashboard de performance
{
  "title": "Backstage Performance",
  "panels": [
    {
      "title": "Response Time",
      "type": "graph",
      "targets": [
        {
          "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
          "legendFormat": "95th percentile"
        }
      ]
    },
    {
      "title": "Error Rate",
      "type": "stat",
      "targets": [
        {
          "expr": "rate(http_requests_total{status_code=~\"5..\"}[5m]) / rate(http_requests_total[5m]) * 100",
          "format": "percent"
        }
      ]
    }
  ]
}
```

### 🔴 **Avanzadas**

#### 📈 **SLOs y SLIs**
```yaml
# ✅ Service Level Objectives
service_level_objectives:
  availability:
    target: 99.9%
    window: 30d
    sli: (1 - (rate(http_requests_total{status_code=~"5.."}[30d]) / rate(http_requests_total[30d])))

  latency:
    target: 95% < 500ms
    window: 30d
    sli: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[30d]))

  throughput:
    target: 1000 req/s
    window: 1h
    sli: rate(http_requests_total[1h])
```

#### 🤖 **Auto-remediation**
```yaml
# ✅ Alertas con acciones automáticas
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: auto-remediation-alerts
spec:
  groups:
  - name: auto-remediation
    rules:
    - alert: PodRestartRequired
      expr: kube_pod_container_status_restarts_total > 5
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "Pod requires restart"
        runbook_url: "https://internal.runbook/pod-restart"
        auto_remediation: "kubectl delete pod {{ $labels.pod }} -n {{ $labels.namespace }}"
```

---

## 🚀 DevOps - CI/CD & Automation

### 🟢 **Esenciales**

#### 🔄 **GitOps Workflow**
```yaml
# ✅ GitOps con ArgoCD
# .github/workflows/deploy.yml
name: Deploy to Production
on:
  push:
    branches: [main]
    paths:
      - 'Manifest/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Update ArgoCD Application
        run: |
          # ArgoCD detectará cambios automáticamente
          # No se necesita acción manual
```

#### 🧪 **Testing Strategy**
```yaml
# ✅ Testing pyramid
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        test: [unit, integration, e2e]
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'yarn'

      - name: Install dependencies
        run: yarn install --frozen-lockfile

      - name: Run ${{ matrix.test }} tests
        run: yarn test:${{ matrix.test }}

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        if: matrix.test == 'unit'
```

### 🟡 **Recomendadas**

#### 🚀 **Blue-Green Deployment**
```yaml
# ✅ Blue-green strategy
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: backstage-blue
spec:
  project: default
  source:
    repoURL: https://github.com/org/backstage-manifests
    targetRevision: HEAD
    path: blue
  destination:
    server: https://kubernetes.default.svc
    namespace: backstage-manual

---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: backstage-green
spec:
  project: default
  source:
    repoURL: https://github.com/org/backstage-manifests
    targetRevision: HEAD
    path: green
  destination:
    server: https://kubernetes.default.svc
    namespace: backstage-manual
```

### 🔴 **Avanzadas**

#### 🤖 **Infrastructure as Code**
```typescript
// ✅ IaC con CDK8s o similar
import { App, Chart } from 'cdk8s';
import { Deployment, Service } from './imports/k8s';

const app = new App();
const chart = new Chart(app, 'backstage');

new Deployment(chart, 'backstage-deployment', {
  spec: {
    replicas: 3,
    selector: {
      matchLabels: { app: 'backstage' }
    },
    template: {
      metadata: { labels: { app: 'backstage' } },
      spec: {
        containers: [{
          name: 'backstage',
          image: 'backstage:latest',
          ports: [{ containerPort: 7007 }],
          resources: {
            requests: { memory: '512Mi', cpu: '250m' },
            limits: { memory: '1Gi', cpu: '500m' }
          }
        }]
      }
    }
  }
});

app.synth();
```

---

## 🐘 Base de Datos - PostgreSQL Best Practices

### 🟢 **Esenciales**

#### ⚙️ **Configuración Óptima**
```sql
-- ✅ Configuración de PostgreSQL
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET checkpoint_completion_target = '0.9';
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = '100';
```

#### 🔄 **Backup Strategy**
```bash
# ✅ Backup automatizado
#!/bin/bash
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backstage_backup_${TIMESTAMP}.sql"

# Crear backup
kubectl exec -n backstage-manual deployment/postgres -- \
  pg_dump -U backstage backstage > "${BACKUP_FILE}"

# Comprimir
gzip "${BACKUP_FILE}"

# Limpiar backups antiguos (mantener 7 días)
find "${BACKUP_DIR}" -name "*.sql.gz" -mtime +7 -delete
```

### 🟡 **Recomendadas**

#### 📊 **Monitoring Queries**
```sql
-- ✅ Queries importantes para monitorear
-- Conexiones activas
SELECT count(*) as active_connections FROM pg_stat_activity;

-- Tamaño de la base de datos
SELECT pg_size_pretty(pg_database_size('backstage'));

-- Queries lentas
SELECT pid, now() - pg_stat_activity.query_start AS duration, query
FROM pg_stat_activity
WHERE state = 'active' AND now() - pg_stat_activity.query_start > interval '1 minute'
ORDER BY duration DESC;

-- Índices no utilizados
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_scan = 0;
```

### 🔴 **Avanzadas**

#### ⚡ **Performance Tuning**
```sql
-- ✅ Partitioning para tablas grandes
CREATE TABLE catalog_entity_partitioned (
    id SERIAL,
    name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (created_at);

-- Crear particiones mensuales
CREATE TABLE catalog_entity_2024_01 PARTITION OF catalog_entity_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- Índices optimizados
CREATE INDEX CONCURRENTLY idx_catalog_entity_name_gin
ON catalog_entity USING gin (name gin_trgm_ops);

-- Connection pooling con PgBouncer
# pgbouncer.ini
[databases]
backstage = host=postgres port=5432 dbname=backstage

[pgbouncer]
listen_port = 6432
listen_addr = *
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 20
reserve_pool_size = 5
```

---

## 📋 Checklist de Implementación

### 🏗️ **Por Entorno**

#### 🧪 **Desarrollo**
- [ ] Variables de entorno locales
- [ ] Logs detallados activados
- [ ] Hot reload configurado
- [ ] Base de datos de desarrollo
- [ ] Tests automatizados en CI

#### 🏭 **Staging**
- [ ] Configuración similar a producción
- [ ] Secrets de staging
- [ ] Monitoreo básico
- [ ] Backup diario
- [ ] Acceso restringido

#### 🚀 **Producción**
- [ ] Secrets en secret manager
- [ ] Monitoreo completo
- [ ] Backup automatizado
- [ ] High availability
- [ ] Disaster recovery plan

### 📊 **Métricas de Calidad**

| Aspecto | Métrica | Target |
|---------|---------|--------|
| **Disponibilidad** | Uptime | 99.9% |
| **Performance** | Response Time P95 | <500ms |
| **Seguridad** | Vulnerabilidades Críticas | 0 |
| **Cobertura Tests** | Code Coverage | >80% |
| **Tiempo de Deploy** | Deployment Time | <10min |

---

<div align="center">

**🏆 Mejores prácticas que escalan**

*¡La excelencia se construye con hábitos consistentes!*

[![DevOps](https://img.shields.io/badge/DevOps-Best--Practices-FF6B6B?style=for-the-badge&logo=devdotto&logoColor=white)](#)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Expert-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)

</div>