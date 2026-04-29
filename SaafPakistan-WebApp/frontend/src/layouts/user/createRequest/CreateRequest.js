import UserDashboardLayout from "examples/LayoutContainers/UserDashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import Grid from "@mui/material/Grid";
import Card from "@mui/material/Card";
import MDButton from "components/MDButton";
import MDInput from "components/MDInput";
import { useContext, useState } from "react";
import { AuthContext } from "context/AuthContext";
import { getAuth } from "firebase/auth";
import * as apiService from "../../api-service";
import { useNavigate } from "react-router-dom";
import MDSnackbar from "components/MDSnackbar";
import Select from "@mui/material/Select";
import MenuItem from "@mui/material/MenuItem";
import InputLabel from "@mui/material/InputLabel";
import FormControl from "@mui/material/FormControl";
import TextField from "@mui/material/TextField";

function CreateRequest() {
  const { currentUser } = useContext(AuthContext);
  const [loading, setLoading] = useState(false);
  const [snackbar, setSnackbar] = useState({ open: false, message: "", color: "success" });
  const navigate = useNavigate();
  const auth = getAuth();

  const [formData, setFormData] = useState({
    address: "",
    wasteType: "",
    date: "",
    time: "",
    notes: "",
  });

  const wasteTypes = [
    "Plastic",
    "Paper/Cardboard",
    "Metal",
    "Glass",
    "Electronics",
    "Mixed Recyclables",
    "Other",
  ];

  const timeSlots = [
    "09:00 - 11:00",
    "11:00 - 13:00",
    "13:00 - 15:00",
    "15:00 - 17:00",
    "17:00 - 19:00",
  ];

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validate required fields
    if (!formData.address || !formData.wasteType || !formData.date || !formData.time) {
      setSnackbar({
        open: true,
        message: "Please fill in all required fields",
        color: "error",
      });
      return;
    }

    setLoading(true);
    try {
      if (auth.currentUser) {
        const idToken = await auth.currentUser.getIdToken();
        await apiService.createUserRequest({
          userIdToken: idToken,
          data: formData,
        });

        setSnackbar({
          open: true,
          message: "Pickup request created successfully!",
          color: "success",
        });

        // Redirect to my requests after a short delay
        setTimeout(() => {
          navigate("/user/requests");
        }, 1500);
      }
    } catch (error) {
      console.error("Error creating request:", error);
      setSnackbar({
        open: true,
        message: error.response?.data?.error || "Failed to create request. Please try again.",
        color: "error",
      });
    } finally {
      setLoading(false);
    }
  };

  const closeSnackbar = () => {
    setSnackbar({ ...snackbar, open: false });
  };

  return (
    <UserDashboardLayout>
      <DashboardNavbar />
      <MDBox py={3}>
        <MDBox mb={4}>
          <MDTypography variant="h4" fontWeight="bold" gutterBottom>
            Create Pickup Request
          </MDTypography>
          <MDTypography variant="body1" color="text">
            Fill in the details below to request a recycling pickup.
          </MDTypography>
        </MDBox>

        <Grid container spacing={3}>
          <Grid item xs={12} md={8}>
            <Card>
              <MDBox
                mx={2}
                mt={-3}
                py={3}
                px={2}
                variant="gradient"
                bgColor="info"
                borderRadius="lg"
                coloredShadow="info"
              >
                <MDTypography variant="h6" color="white" fontWeight="medium">
                  Pickup Details
                </MDTypography>
              </MDBox>
              <MDBox p={3}>
                <form onSubmit={handleSubmit}>
                  <Grid container spacing={3}>
                    <Grid item xs={12}>
                      <MDInput
                        type="text"
                        label="Address *"
                        name="address"
                        value={formData.address}
                        onChange={handleChange}
                        fullWidth
                        variant="standard"
                        placeholder="Enter your pickup address"
                      />
                    </Grid>

                    <Grid item xs={12} sm={6}>
                      <FormControl fullWidth variant="standard">
                        <InputLabel id="waste-type-label">
                          Waste Type *
                        </InputLabel>
                        <Select
                          labelId="waste-type-label"
                          name="wasteType"
                          value={formData.wasteType}
                          onChange={handleChange}
                          label="Waste Type *"
                        >
                          {wasteTypes.map((type) => (
                            <MenuItem key={type} value={type}>
                              {type}
                            </MenuItem>
                          ))}
                        </Select>
                      </FormControl>
                    </Grid>

                    <Grid item xs={12} sm={6}>
                      <TextField
                        fullWidth
                        label="Pickup Date *"
                        type="date"
                        name="date"
                        value={formData.date}
                        onChange={handleChange}
                        InputLabelProps={{
                          shrink: true,
                        }}
                        inputProps={{
                          min: new Date().toISOString().split('T')[0],
                        }}
                      />
                    </Grid>

                    <Grid item xs={12} sm={6}>
                      <FormControl fullWidth variant="standard">
                        <InputLabel id="time-slot-label">
                          Time Slot *
                        </InputLabel>
                        <Select
                          labelId="time-slot-label"
                          name="time"
                          value={formData.time}
                          onChange={handleChange}
                          label="Time Slot *"
                        >
                          {timeSlots.map((slot) => (
                            <MenuItem key={slot} value={slot}>
                              {slot}
                            </MenuItem>
                          ))}
                        </Select>
                      </FormControl>
                    </Grid>

                    <Grid item xs={12} sm={6}>
                      <MDInput
                        type="text"
                        label="Additional Notes"
                        name="notes"
                        value={formData.notes}
                        onChange={handleChange}
                        fullWidth
                        variant="standard"
                        placeholder="Any special instructions"
                      />
                    </Grid>

                    <Grid item xs={12}>
                      <MDBox display="flex" gap={2} justifyContent="flex-end">
                        <MDButton
                          variant="outlined"
                          color="info"
                          onClick={() => navigate("/user/dashboard")}
                          disabled={loading}
                        >
                          Cancel
                        </MDButton>
                        <MDButton
                          type="submit"
                          variant="gradient"
                          color="info"
                          disabled={loading}
                        >
                          {loading ? "Submitting..." : "Submit Request"}
                        </MDButton>
                      </MDBox>
                    </Grid>
                  </Grid>
                </form>
              </MDBox>
            </Card>
          </Grid>

          <Grid item xs={12} md={4}>
            <Card>
              <MDBox
                mx={2}
                mt={-3}
                py={3}
                px={2}
                variant="gradient"
                bgColor="warning"
                borderRadius="lg"
                coloredShadow="warning"
              >
                <MDTypography variant="h6" color="white" fontWeight="medium">
                  Important Information
                </MDTypography>
              </MDBox>
              <MDBox p={3}>
                <MDTypography variant="body2" color="text" paragraph>
                  <strong>Before submitting:</strong>
                </MDTypography>
                <MDTypography variant="body2" color="text" component="div">
                  <ul style={{ paddingLeft: "20px", margin: 0 }}>
                    <li>Ensure the address is accurate and accessible</li>
                    <li>Sort your recyclables by type if possible</li>
                    <li>Be available at the selected time slot</li>
                    <li>Keep recyclables ready for collection</li>
                  </ul>
                </MDTypography>
                <MDTypography variant="body2" color="text" sx={{ mt: 2 }}>
                  <strong>Accepted items:</strong> Plastic bottles, paper, cardboard,
                  metal cans, glass bottles, electronics.
                </MDTypography>
                <MDTypography variant="body2" color="text" sx={{ mt: 1 }}>
                  <strong>Not accepted:</strong> Hazardous materials, medical waste,
                  construction debris.
                </MDTypography>
              </MDBox>
            </Card>
          </Grid>
        </Grid>
      </MDBox>

      <MDSnackbar
        open={snackbar.open}
        onClose={closeSnackbar}
        message={snackbar.message}
        color={snackbar.color}
        autoHideDuration={4000}
        location="top"
        close={closeSnackbar}
      />
    </UserDashboardLayout>
  );
}

export default CreateRequest;