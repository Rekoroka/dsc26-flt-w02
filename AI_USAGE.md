# AI usage: dsc26-flt-w02

## 1. Tools I used

- ChatGPT to understand the task, write and fix code, and solve test problems.
- Flutter CLI to run tests and check my code.
- Dart and Flutter documentation to learn more about the code.

## 2. The two or three most useful prompts

1. Help me write `StockAlert` methods to read data, copy an alert, and compare alerts.
2. Help me add search, filters, sorting, and acknowledge actions to `AlertsViewModel`.
3. Help me fix the app so it shows the alerts screen and passes the tests.

## 3. One thing the AI got wrong or left out, and how I found it

At first, the app did not show the alerts screen. The tests failed because they could not find the alerts or the critical filter. I checked the problem, fixed the app setup, and ran the tests again.

## 4. Why `visibleAlerts` lives in the view model and not in the screen

The view model searches, filters, and sorts the alerts. The screen only shows the alerts and lets the user interact with them. This makes the code easier to test and understand.