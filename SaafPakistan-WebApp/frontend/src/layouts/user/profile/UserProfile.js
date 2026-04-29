import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import MDBox from "components/MDBox";
import MDTypography from "components/MDTypography";
import Grid from "@mui/material/Grid";
import Card from "@mui/material/Card";
import MDButton from "components/MDButton";
import MDInput from "components/MDInput";
import { useContext, useEffect, useState } from "react";
import { AuthContext } from "context/AuthContext";
import { getAuth } from "firebase/auth";
import * as apiService from "../../api-service";
import { useNavigate } from "react-router-dom";
import MDSnackbar from "components/MDSnackbar";
import Avatar from "@mui/material/Avatar";
import Divider from "@mui/material/Divider";
import CircularProgress from "@mui/material/CircularProgress";
import PersonIcon from "@mui/icons-material/Person";
import EmailIcon from "@mui/icons-material/Email";
import PhoneIcon from "@mui/icons-material/Phone";
import LocationOnIcon from "@mui/icons-material/LocationOn";
import LocalShippingIcon from "@mui/icons-material/LocalShipping";
import CheckCircleIcon from "@mui/icons-material/CheckCircle";
import PendingIcon from "@mui/icons-material/Pending";
import AssignmentIcon from "@mui/icons-material/Assignment";

function UserProfile() {
  const { currentUser } = useContext(AuthContext);
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [snackbar, setSnackbar] = useState({ open: false, message: "", color: "success" });
  const navigate = useNavigate();
  const auth = getAuth();

  const [formData, setFormData] = useState({
    name: "",
    phone: "",
    address: "",
  });

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        if (auth.currentUser) {
          const idToken = await auth.currentUser.getIdToken();
          const data = await apiService.getUserProfile({ userIdToken: idToken });
          setProfile(data);
          setFormData({
            name: data.name || "",
            phone: data.phone || "",
            address: data.address || "",
          });
        }
      } catch (error) {
        console.error("Error fetching profile:", error);
        setSnackbar({
          open: true,
          message: "Failed to load profile",
          color: "error",
        });
      } finally {
        setLoading(false);
      }
    };

    fetchProfile();
  }, [auth]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleEditToggle = () => {
    if (editing && profile) {
      setFormData({
        name: profile.name || "",
        phone: profile.phone || "",
        address: profile.address || "",
      });
    }
    setEditing(!editing);
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      const idToken = await auth.currentUser.getIdToken();
      await apiService.updateUserProfile({
        userIdToken: idToken,
        data: formData,
      });

      setProfile((prev) => ({
        ...prev,
        ...formData,
      }));

      setSnackbar({
        open: true,
        message: "Profile updated successfully",
        color: "success",
      });
      setEditing(false);
    } catch (error) {
      console.error("Error updating profile:", error);
      setSnackbar({
        open: true,
        message: error.response?.data?.error || "Failed to update profile",
        color: "error",
      });
    } finally {
      setSaving(false);
    }
  };

  const handleLogout = async () => {
    try {
      await auth.signOut();
      localStorage.removeItem("user");
      localStorage.removeItem("role");
      navigate("/login");
    } catch (error) {
      console.error("Error logging out:", error);
    }
  };

  const closeSnackbar = () => {
    setSnackbar({ ...snackbar, open: false });
  };

  if (loading) {
    return (
      <DashboardLayout>
        <DashboardNavbar />
        <MDBox display="flex" justifyContent="center" alignItems="center" minHeight="50vh">
          <CircularProgress />
        </MDBox>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <DashboardNavbar />
      <MDBox py={3}>
        <MDBox mb={4}>
          <MDTypography variant="h4" fontWeight="bold" gutterBottom>
            My Profile
          </MDTypography>
          <MDTypography variant="body1" color="text">
            View and manage your account information.
          </MDTypography>
        </MDBox>

        <Grid container spacing={3}>
          {/* Profile Information Card */}
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
                  Account Information
                </MDTypography>
              </MDBox>
              <MDBox p={3}>
                <Grid container spacing={3}>
                  <Grid item xs={12} display="flex" justifyContent="center" mb={3}>
                    <Avatar
                      sx={{
                        width: 100,
                        height: 100,
                        bgcolor: "info.main",
                        fontSize: "3rem",
                      }}
                    >
                      {profile?.name?.charAt(0).toUpperCase() || "U"}
                    </Avatar>
                  </Grid>

                  <Grid item xs={12}>
                    <Divider />
                  </Grid>

                  <Grid item xs={12} sm={6}>
                    <MDBox display="flex" alignItems="center" gap={2}>
                      <PersonIcon color="info" />
                      <MDBox width="100%">
                        <MDTypography variant="caption" color="text">
                          Name
                        </MDTypography>
                        {editing ? (
                          <MDInput
                            fullWidth
                            name="name"
                            value={formData.name}
                            onChange={handleChange}
                            variant="standard"
                          />
                        ) : (
                          <MDTypography variant="body1" fontWeight="medium">
                            {profile?.name || "Not set"}
                          </MDTypography>
                        )}
                      </MDBox>
                    </MDBox>
                  </Grid>

                  <Grid item xs={12} sm={6}>
                    <MDBox display="flex" alignItems="center" gap={2}>
                      <EmailIcon color="info" />
                      <MDBox width="100%">
                        <MDTypography variant="caption" color="text">
                          Email
                        </MDTypography>
                        <MDTypography variant="body1" fontWeight="medium">
                          {profile?.email || "Not set"}
                        </MDTypography>
                      </MDBox>
                    </MDBox>
                  </Grid>

                  <Grid item xs={12} sm={6}>
                    <MDBox display="flex" alignItems="center" gap={2}>
                      <PhoneIcon color="info" />
                      <MDBox width="100%">
                        <MDTypography variant="caption" color="text">
                          Phone
                        </MDTypography>
                        {editing ? (
                          <MDInput
                            fullWidth
                            name="phone"
                            value={formData.phone}
                            onChange={handleChange}
                            variant="standard"
                          />
                        ) : (
                          <MDTypography variant="body1" fontWeight="medium">
                            {profile?.phone || "Not set"}
                          </MDTypography>
                        )}
                      </MDBox>
                    </MDBox>
                  </Grid>

                  <Grid item xs={12} sm={6}>
                    <MDBox display="flex" alignItems="center" gap={2}>
                      <LocationOnIcon color="info" />
                      <MDBox width="100%">
                        <MDTypography variant="caption" color="text">
                          Address
                        </MDTypography>
                        {editing ? (
                          <MDInput
                            fullWidth
                            name="address"
                            value={formData.address}
                            onChange={handleChange}
                            variant="standard"
                          />
                        ) : (
                          <MDTypography variant="body1" fontWeight="medium">
                            {profile?.address || "Not set"}
                          </MDTypography>
                        )}
                      </MDBox>
                    </MDBox>
                  </Grid>

                  <Grid item xs={12}>
                    <MDBox display="flex" gap={2} justifyContent="flex-end" mt={2}>
                      {editing ? (
                        <>
                          <MDButton
                            variant="outlined"
                            color="info"
                            onClick={handleEditToggle}
                            disabled={saving}
                          >
                            Cancel
                          </MDButton>
                          <MDButton
                            variant="gradient"
                            color="info"
                            onClick={handleSave}
                            disabled={saving}
                          >
                            {saving ? "Saving..." : "Save Changes"}
                          </MDButton>
                        </>
                      ) : (
                        <MDButton
                          variant="gradient"
                          color="info"
                          onClick={handleEditToggle}
                        >
                          Edit Profile
                        </MDButton>
                      )}
                    </MDBox>
                  </Grid>
                </Grid>
              </MDBox>
            </Card>
          </Grid>

          {/* Stats Card */}
          <Grid item xs={12} md={4}>
            <Card sx={{ mb: 3 }}>
              <MDBox
                mx={2}
                mt={-3}
                py={3}
                px={2}
                variant="gradient"
                bgColor="success"
                borderRadius="lg"
                coloredShadow="success"
              >
                <MDTypography variant="h6" color="white" fontWeight="medium">
                  Request Statistics
                </MDTypography>
              </MDBox>
              <MDBox p={3}>
                <MDBox display="flex" alignItems="center" justifyContent="space-between" mb={2}>
                  <MDBox display="flex" alignItems="center" gap={1}>
                    <PendingIcon color="warning" />
                    <MDTypography variant="body2">Pending</MDTypography>
                  </MDBox>
                  <MDTypography variant="h6">
                    {profile?.stats?.pendingRequests || 0}
                  </MDTypography>
                </MDBox>
                <MDBox display="flex" alignItems="center" justifyContent="space-between" mb={2}>
                  <MDBox display="flex" alignItems="center" gap={1}>
                    <AssignmentIcon color="info" />
                    <MDTypography variant="body2">Assigned</MDTypography>
                  </MDBox>
                  <MDTypography variant="h6">
                    {profile?.stats?.assignedRequests || 0}
                  </MDTypography>
                </MDBox>
                <MDBox display="flex" alignItems="center" justifyContent="space-between" mb={2}>
                  <MDBox display="flex" alignItems="center" gap={1}>
                    <CheckCircleIcon color="success" />
                    <MDTypography variant="body2">Completed</MDTypography>
                  </MDBox>
                  <MDTypography variant="h6">
                    {profile?.stats?.completedRequests || 0}
                  </MDTypography>
                </MDBox>
                <Divider sx={{ my: 2 }} />
                <MDBox display="flex" alignItems="center" justifyContent="space-between">
                  <MDBox display="flex" alignItems="center" gap={1}>
                    <LocalShippingIcon color="primary" />
                    <MDTypography variant="body2" fontWeight="medium">Total</MDTypography>
                  </MDBox>
                  <MDTypography variant="h5" fontWeight="bold" color="primary">
                    {profile?.stats?.totalRequests || 0}
                  </MDTypography>
                </MDBox>
              </MDBox>
            </Card>

            {/* Logout Card */}
            <Card>
              <MDBox p={3}>
                <MDButton
                  variant="outlined"
                  color="error"
                  fullWidth
                  size="large"
                  onClick={handleLogout}
                >
                  Logout
                </MDButton>
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
    </DashboardLayout>
  );
}

export default UserProfile;