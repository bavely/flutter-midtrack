# meditrack_flutter

A new Flutter project.

## Configuring the API endpoint

The app picks a default GraphQL server URL based on the `ENV` value
supplied via `--dart-define` when running the app:

| ENV value    | API base URL                         |
|--------------|--------------------------------------|
| development  | http://192.168.50.5:8000/graphql     |
| emulator     | http://10.0.2.2:8000/graphql         |
| production   | https://midtrack.example.com/graphql |

To point the app to a specific server, override the URL directly:

```bash
flutter run --dart-define=API_BASE_URL=http://<your-ip>:8000/graphql
```

You can also select one of the preset environments:

```bash
flutter run --dart-define=ENV=emulator
```
