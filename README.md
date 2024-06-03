# Testing

### _1. Registration_

```json
curl -X POST -H 'Content-Type: application/json' -d '{"user":{"fio": "My name is", "email": "user@gmail.com", "password": "...", "teacher": "true"}}' http://127.0.0.1:3000/api/reg
```

<br>

### _2. Authorization_

```json
curl -X POST -H 'Content-Type: application/json' -H 'Authorization: Bareer jwt'-d '{"user":{"email": "user@gmail.com", "password": "..."}}' http://127.0.0.1:3000/api/session
```

<br>

### _3. Making course_

```json
curl -X POST -H 'Content-Type: application/json' -H 'Authorization: Bareer {jwt}' -d '{"course":{"title": "course name", "description": "The best course"}}' http://127.0.0.1:3000/api/courses
```

Be sure that your user is Teacher.

Don't forget to paste your jwt_token. (from 2. Authorization)

<br>

### _4. Get list of courses_

```json
curl -X GET -H 'Content-Type: application/json' -H 'Authorization: Bareer {jwt}' -d '{"pagination":{"page": "1", "limit": "5"}}' http://127.0.0.1:3000/api/courses
```

If you want to get courses of certain teacher, so add to json:
> "id_teach": "123"

or if you want to find courses by certain student, so add to json:
> "id_stud": "123"

<br>

### _5. Get info about certain course_

```json
curl -X GET -H 'Content-Type: application/json' -H 'Authorization: Bareer {jwt}' http://127.0.0.1:3000/api/courses/1
```
<br>

### _6. Subscribe on course_

```json
curl -X POST -H 'Content-Type: application/json' -H 'Authorization: Bareer {jwt}' -d '{"course_id": "1"}' http://127.0.0.1:3000/api/courses/1/subscribe
```
Be sure that your user is Student.