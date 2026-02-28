namespace Domain.Entities
{
    public class Account
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(20)]
        public string PhoneNumber { get; set; }

        [Required]
        public string PasswordHash { get; set; }

        [Required, MaxLength(20)]
        public string Role { get; set; } // Admin, Staff, Student

        // Navigation Properties (1-1)
        public Student Student { get; set; }
        public Staff Staff { get; set; }
    }
}
