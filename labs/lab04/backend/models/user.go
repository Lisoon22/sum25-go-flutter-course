package models

import (
	"database/sql"
	"fmt"
	"regexp"
	"time"
)

// User represents a user in the system
type User struct {
	ID        int       `json:"id" db:"id"`
	Name      string    `json:"name" db:"name"`
	Email     string    `json:"email" db:"email"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// CreateUserRequest represents the payload for creating a user
type CreateUserRequest struct {
	Name  string `json:"name"`
	Email string `json:"email"`
}

// UpdateUserRequest represents the payload for updating a user
type UpdateUserRequest struct {
	Name  *string `json:"name,omitempty"`
	Email *string `json:"email,omitempty"`
}

// TODO: Implement Validate method for User
func (u *User) Validate() error {
	// Name should not be empty and should be at least 2 characters
	if len(u.Name) < 2 {
		return fmt.Errorf("name must be at least 2 characters")
	}
	// Email should be valid format (simple regex)
	if u.Email == "" {
		return fmt.Errorf("email must not be empty")
	}
	// Very simple email validation
	emailRe := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	if !emailRe.MatchString(u.Email) {
		return fmt.Errorf("email is not valid")
	}
	return nil
}

// TODO: Implement Validate method for CreateUserRequest
func (req *CreateUserRequest) Validate() error {
	// Name should not be empty and should be at least 2 characters
	if len(req.Name) < 2 {
		return fmt.Errorf("name must be at least 2 characters")
	}
	// Email should not be empty
	if req.Email == "" {
		return fmt.Errorf("email must not be empty")
	}
	// Simple email validation
	emailRe := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	if !emailRe.MatchString(req.Email) {
		return fmt.Errorf("email is not valid")
	}
	return nil
}

// TODO: Implement ToUser method for CreateUserRequest
func (req *CreateUserRequest) ToUser() *User {
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

// TODO: Implement ScanRow method for User
func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		return fmt.Errorf("row is nil")
	}
	return row.Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
		&u.UpdatedAt,
	)
}

// TODO: Implement ScanRows method for User slice
func ScanUsers(rows *sql.Rows) ([]User, error) {
	defer rows.Close()
	var users []User
	for rows.Next() {
		var u User
		err := rows.Scan(
			&u.ID,
			&u.Name,
			&u.Email,
			&u.CreatedAt,
			&u.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return users, nil
}
