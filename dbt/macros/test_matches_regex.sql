{% test matches_regex(model, column_name, pattern) %}

SELECT
  {{ column_name }}
FROM
  {{ model }}
WHERE
  {{ column_name }} IS NOT NULL
  AND NOT REGEXP_LIKE({{ column_name }}, '{{ pattern }}')

{% endtest %}
