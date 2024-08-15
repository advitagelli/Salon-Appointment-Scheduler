#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {

  echo -e "\nWelcome to My Salon, how can I help you?"

  SERVICES_OFFERED=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES_OFFERED" | while read SERVICE_ID BAR SERVICE
  do
    if [[ $SERVICE_ID =~ ^[0-9]+$ ]]
    then
      echo "$SERVICE_ID) $SERVICE"
    fi
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then 
    echo -e "\nI could not find that service. What would you like today?"
    MAIN_MENU

  else 
    SERVICE_SELECTED_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_SELECTED_NAME ]]
    then
      echo -e "\nI could not find that service. What would you like today?"
      MAIN_MENU

    else 
      GET_CUSTOMER_INFO $SERVICE_SELECTED_NAME

    fi
  fi

}

GET_CUSTOMER_INFO() {
  echo -e "\nWhat's your phone number??"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then 
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_INTO_CUSTOMERS=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ *//')

  echo -e "\nWhat time would you like your $1, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME


  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME_FORMATTED'")
  SEL_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name='$1'")
  echo CUSTOMER ID IS $CUSTOMER_ID AND SERVICE ID IS $SEL_SERVICE_ID
  INSERT_INTO_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SEL_SERVICE_ID, '$SERVICE_TIME')")

  echo "I have put you down for a $1 at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}

MAIN_MENU
